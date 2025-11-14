import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/order_provider.dart';
import '../../controllers/cart_controller.dart';
import '../../models/table_model.dart';
import '../../models/order_type_model.dart';
import '../../theme/theme.dart';
import '../../utils/scroll_behavior_utils.dart';
import '../../widgets/table_shimmer_widget.dart';
import '../../widgets/order_success_popup.dart';
import '../../storage/local_storage.dart';

/// Table selection screen with floor tabs and table grid
/// 
/// This screen allows users to select tables from different floors
/// for their order. It features:
/// - Floor-based tab navigation
/// - Grid view of tables with selection capability
/// - Shimmer loading effects
/// - Responsive design for mobile and tablet
/// - Display of selected service type
class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;
  OrderTypeModel? _selectedOrderType;
  
  // Number of guests controller and focus node
  final TextEditingController _guestsController = TextEditingController(text: '1');
  final FocusNode _guestsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Get selected order type from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['selectedOrderType'] is OrderTypeModel) {
        _selectedOrderType = args['selectedOrderType'] as OrderTypeModel;
      }
      
      // Fetch table data when screen loads
      context.read<TableProvider>().fetchTableList();
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    _guestsController.dispose();
    _guestsFocusNode.dispose();
    super.dispose();
  }

  /// Handle tab change
  void _onTabChanged() {
    if (_tabController != null && _tabController!.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController!.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<TableProvider>(
        builder: (context, tableProvider, child) {
          // Show shimmer loading while data is being fetched
          if (tableProvider.isLoading) {
            return const TableShimmerWidget();
          }

          // Show error state if there's an error
          if (tableProvider.errorMessage != null) {
            return _buildErrorState(context, tableProvider);
          }

          // Show empty state if no floors available
          if (tableProvider.floors.isEmpty) {
            return _buildEmptyState(context);
          }

          // Initialize or update tab controller when floors are loaded
          if (tableProvider.floors.isNotEmpty) {
            if (_tabController == null || _tabController!.length != tableProvider.floors.length) {
              _tabController?.dispose();
              _tabController = TabController(
                length: tableProvider.floors.length,
                vsync: this,
                initialIndex: _currentTabIndex.clamp(0, tableProvider.floors.length - 1),
              );
              _tabController!.addListener(_onTabChanged);
            }
          }

          return _buildTableSelectionContent(context, tableProvider);
        },
      ),
    );
  }

  /// Build app bar with title and back button
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Table',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Consumer<TableProvider>(
          builder: (context, tableProvider, child) {
            if (tableProvider.hasSelectedTables) {
              return TextButton(
                onPressed: () => tableProvider.clearAllSelections(),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Build table selection content with tabs and grid
  Widget _buildTableSelectionContent(BuildContext context, TableProvider tableProvider) {
    return Column(
      children: [
        // Floor tabs
        _buildFloorTabs(context, tableProvider),
        
        // Table grid
        Expanded(
          child: _tabController != null
              ? TabBarView(
                  controller: _tabController!,
                  children: tableProvider.floors.map((floor) {
                    return _buildFloorTableGrid(context, tableProvider, floor);
                  }).toList(),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
        
        // Confirm selection button
        _buildConfirmSelectionButton(context, tableProvider),
      ],
    );
  }

  /// Build floor tabs
  Widget _buildFloorTabs(BuildContext context, TableProvider tableProvider) {
    if (_tabController == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: Responsive.padding(context, 48),
      margin: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 16)),
      child: TabBar(
        controller: _tabController!,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: Responsive.fontSize(context, 14),
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: Responsive.fontSize(context, 14),
        ),
        tabs: tableProvider.floors.map((floor) {
          return Tab(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, 16),
                vertical: Responsive.padding(context, 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(floor.floorName),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build table grid for a specific floor
  Widget _buildFloorTableGrid(BuildContext context, TableProvider tableProvider, FloorModel floor) {
    return ScrollConfiguration(
      behavior: ScrollBehaviorUtils.createCrossPlatformScrollBehavior(),
      child: GridView.builder(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: Responsive.padding(context, 12),
          mainAxisSpacing: Responsive.padding(context, 12),
          childAspectRatio: 1.2,
        ),
        itemCount: floor.tables.length,
        itemBuilder: (context, index) {
          final table = floor.tables[index];
          return _buildTableCard(context, tableProvider, table);
        },
      ),
    );
  }

  /// Build individual table card
  Widget _buildTableCard(BuildContext context, TableProvider tableProvider, TableModel table) {
    final isSelected = tableProvider.isTableSelected(table.tableId);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => tableProvider.toggleTableSelection(table.tableId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(Responsive.padding(context, 16)),
          child: Text(
            table.tableName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.fontSize(context, 16),
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// Build confirm selection button
  Widget _buildConfirmSelectionButton(BuildContext context, TableProvider tableProvider) {
    if (!tableProvider.hasSelectedTables) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Number of guests input
          _buildNumberOfGuestsField(context),
          SizedBox(height: Responsive.padding(context, 16)),
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: Responsive.padding(context, 52),
            child: ElevatedButton(
              onPressed: () => _confirmSelection(context, tableProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Consumer<TableProvider>(
                builder: (context, tableProvider, child) {
                  final count = tableProvider.selectedTableCount;
                  return Text(
                    'Confirm Selection (${count} table)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 16),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build number of guests input field
  Widget _buildNumberOfGuestsField(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: _guestsController,
      focusNode: _guestsFocusNode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Number of Guests',
        hintText: 'Enter number of guests',
        prefixIcon: Icon(
          Icons.people_outline,
          color: theme.colorScheme.primary,
          size: Responsive.fontSize(context, 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 16),
          vertical: Responsive.padding(context, 14),
        ),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: Responsive.fontSize(context, 14),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, TableProvider tableProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Responsive.fontSize(context, 80),
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: Responsive.padding(context, 24)),
            Text(
              'Error Loading Tables',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Responsive.padding(context, 8)),
            Text(
              tableProvider.errorMessage ?? 'An unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.padding(context, 32)),
            ElevatedButton(
              onPressed: () => tableProvider.fetchTableList(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 32),
                  vertical: Responsive.padding(context, 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant_outlined,
              size: Responsive.fontSize(context, 80),
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: Responsive.padding(context, 24)),
            Text(
              'No Tables Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: Responsive.padding(context, 8)),
            Text(
              'There are no tables available at the moment.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle confirm selection action
  Future<void> _confirmSelection(BuildContext context, TableProvider tableProvider) async {
    // Validate number of guests
    final guestsText = _guestsController.text.trim();
    if (guestsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the number of guests'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      _guestsFocusNode.requestFocus();
      return;
    }
    
    final numberOfGuests = int.tryParse(guestsText);
    if (numberOfGuests == null || numberOfGuests <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid number of guests (must be greater than 0)'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      _guestsFocusNode.requestFocus();
      return;
    }
    
    // Get the selected table
    final selectedTable = tableProvider.selectedTables.isNotEmpty 
        ? tableProvider.selectedTables.first 
        : null;
    
    if (selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a table first'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Check if order type is selected
    if (_selectedOrderType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order type not selected'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Get cart items
    final cartController = context.read<CartController>();
    if (cartController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cart is empty. Please add items first.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Get branch ID from local storage
    final branchIdString = await LocalStorage.getBranchId();
    if (branchIdString == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Branch not selected. Please restart the app.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final branchId = int.tryParse(branchIdString) ?? 0;
    
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: Responsive.padding(context, 16)),
                  Text(
                    'Placing your order...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: Responsive.fontSize(context, 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Call create order API
    final orderProvider = context.read<OrderProvider>();
    final response = await orderProvider.createOrder(
      cartItems: cartController.cartItems,
      tableId: selectedTable.tableId,
      orderTypeId: _selectedOrderType!.id.toString(),
      branchId: branchId,
      orderNotes: cartController.orderNotes.isNotEmpty ? cartController.orderNotes : null,
      noOfGuest: numberOfGuests,
    );
    
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // Handle response
    if (response != null && response.success) {
      // Clear cart after successful order placement
      await cartController.clearCart();
      
      // Show success popup
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OrderSuccessPopup(orderResponse: response),
        );
      }
    } else {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Failed to place order'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
