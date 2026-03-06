import 'package:call_api_app/models/product.dart';
import 'package:call_api_app/screens/product_detail_page.dart';
import 'package:call_api_app/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();

  late Future<List<Product>> _productsFuture;
  bool _isGridMode = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final products = await _productService.fetchProducts();
    _lastUpdated = DateTime.now();
    return products;
  }

  Future<void> _retryFetchProducts() async {
    setState(() {
      _productsFuture = _fetchProducts();
    });

    await _productsFuture;
  }

  String _lastUpdatedText() {
    if (_lastUpdated == null) {
      return 'Chưa có dữ liệu';
    }

    final hour = _lastUpdated!.hour.toString().padLeft(2, '0');
    final minute = _lastUpdated!.minute.toString().padLeft(2, '0');
    final day = _lastUpdated!.day.toString().padLeft(2, '0');
    final month = _lastUpdated!.month.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month/${_lastUpdated!.year}';
  }

  void _openProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TH3 - [Nghiêm Xuân Trường] - [2351160561]'),
        actions: [
          IconButton(
            tooltip: _isGridMode ? 'Hiển thị dạng danh sách' : 'Hiển thị dạng lưới',
            onPressed: () {
              setState(() {
                _isGridMode = !_isGridMode;
              });
            },
            icon: Icon(_isGridMode ? Icons.view_list : Icons.grid_view),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _StatusView(
              icon: Icons.sync,
              title: 'Đang tải dữ liệu...',
              message: 'Ứng dụng đang gọi API sản phẩm từ mạng.',
              loading: true,
            );
          }

          if (snapshot.hasError) {
            return _StatusView(
              icon: Icons.wifi_off_rounded,
              title: 'Lỗi kết nối',
              message: 'Không thể tải sản phẩm. Hãy kiểm tra Internet và thử lại.',
              actionLabel: 'Thử lại',
              onActionPressed: _retryFetchProducts,
            );
          }

          final products = snapshot.data;
          if (products == null || products.isEmpty) {
            return _StatusView(
              icon: Icons.inventory_2_outlined,
              title: 'Danh sách trống',
              message: 'Hiện tại chưa có sản phẩm để hiển thị.',
              actionLabel: 'Tải lại',
              onActionPressed: _retryFetchProducts,
            );
          }

          return RefreshIndicator(
            onRefresh: _retryFetchProducts,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _SummaryHeader(
                    itemCount: products.length,
                    lastUpdated: _lastUpdatedText(),
                    isGridMode: _isGridMode,
                    onToggleView: () {
                      setState(() {
                        _isGridMode = !_isGridMode;
                      });
                    },
                  ),
                ),
                if (_isGridMode)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return _ProductGridCard(
                            product: product,
                            onTap: () => _openProductDetail(product),
                          );
                        },
                        childCount: products.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.66,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return _ProductListCard(
                            product: product,
                            onTap: () => _openProductDetail(product),
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.itemCount,
    required this.lastUpdated,
    required this.isGridMode,
    required this.onToggleView,
  });

  final int itemCount;
  final String lastUpdated;
  final bool isGridMode;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng sản phẩm: $itemCount',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cập nhật: $lastUpdated',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onToggleView,
                icon: Icon(isGridMode ? Icons.view_list_rounded : Icons.grid_view_rounded),
                label: Text(isGridMode ? 'List' : 'Grid'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final String? actionLabel;
  final Future<void> Function()? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Icon(icon, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (loading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
                if (!loading && actionLabel != null && onActionPressed != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onActionPressed,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  const _ProductListCard({
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(imageUrl: product.image, width: 78, height: 78),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rate_rounded, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating.rate} (${product.rating.count})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _ProductImage(
                  imageUrl: product.image,
                  width: 90,
                  height: 90,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                product.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rate_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.rate.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: width,
          height: height,
          child: const ColoredBox(
            color: Color(0xFFE0E0E0),
            child: Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }
}
