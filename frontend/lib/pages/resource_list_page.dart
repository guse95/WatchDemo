import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/logic/resource_model.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/txt_styles.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback onTap;

  const ResourceCard({
    super.key,
    required this.resource, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, String> imagePaths = {
      "room": "assets/images/back.jpg",
      "laptop": "assets/images/notebook.png",
      "board": "assets/images/board.png",
      "projector": "assets/images/projector.png",
    };

    return Material(
      elevation: 5,
      color: Colors.white,
      shape: IOSLikeShape(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: accentGreenC.withValues(alpha: 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(imagePaths[resource.type]!), fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: TxtStyles.cardTitle.copyWith(color: blackC),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    resource.description,
                    style: TxtStyles.body.copyWith(color: blackC.withValues(alpha: 0.6), height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResourceListPage extends StatefulWidget {
  final ValueChanged<Resource> onResourceSelected;

  const ResourceListPage({super.key, required this.onResourceSelected});

  @override
  State<ResourceListPage> createState() => _ResourceListPageState();
}

class _ResourceListPageState extends State<ResourceListPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;
  int selectedIndex = 0;

  final List<Resource> _resources = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;

  static const int _limit = 24;

  final List<String> _tabNames = ["Все", "Комнаты", "Ноутбуки", "Доски", "Проекторы"];
  final List<String?> _resourceTypes = [null, "room", "laptop", "board", "projector"];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabNames.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != selectedIndex) {
        setState(() {
          selectedIndex = _tabController.index;
        });
        _page = 0;
        _isLoading = false;
        _hasMore = true;
        _resources.clear();
        _loadResources();
      }
    });

    _loadResources();

    _scrollController.addListener(() {
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 500) {
        _loadResources();
      }
    });
  }

  Future<void> _loadResources() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedResourceType = _resourceTypes[selectedIndex];
      final newResources = await HttpRequests().fetchResources(page: _page, limit: _limit, type: selectedResourceType);

      setState(() {
        _resources.addAll(newResources);
        _page++;

        if (newResources.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      logMsg("E", "Load resources", "Error loading resources: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _resources.length + (_hasMore ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Доступные ресурсы", style: TxtStyles.h1.copyWith(color: blackC)),
          const SizedBox(height: 18),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,

            labelPadding: const EdgeInsets.only(right: 24),
            padding: EdgeInsets.zero,

            overlayColor: WidgetStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,

            labelColor: accentGreenC,
            unselectedLabelColor: blackC,
            labelStyle: TxtStyles.sidebarItemActive.copyWith(color: accentGreenC),
            unselectedLabelStyle: TxtStyles.sidebarItem.copyWith(color: accentGreenC),

            indicatorColor: darkGreenC,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,

            dividerColor: Colors.transparent,
            tabs: List.generate(_tabNames.length, (index) {
              return Tab(text: _tabNames[index]);
            }),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              itemCount: itemCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                if (index >= _resources.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: accentGreenC),
                    ),
                  );
                }
                final resource = _resources[index];
                return ResourceCard(resource: resource, onTap: () {
                  widget.onResourceSelected(resource);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
