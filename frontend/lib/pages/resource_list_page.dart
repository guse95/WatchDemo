import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/logic/resource_model.dart';
import 'package:frontend/txt_styles.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;

  const ResourceCard({
    super.key,
    required this.resource,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // переход на страницу ресурса
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(
            //   child: resource.imageUrl != null
            //       ? Image.network(
            //     resource.imageUrl!,
            //     width: double.infinity,
            //     fit: BoxFit.cover,
            //   )
            //       : Container(
            //     width: double.infinity,
            //     color: Colors.grey.shade200,
            //     child: const Icon(Icons.meeting_room, size: 48),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Text(
                  //   resource.location ?? 'Локация не указана',
                  //   style: Theme.of(context).textTheme.bodySmall,
                  // ),
                  // if (resource.capacity != null)
                  //   Text(
                  //     'Вместимость: ${resource.capacity}',
                  //     style: Theme.of(context).textTheme.bodySmall,
                  //   ),
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
  const ResourceListPage({super.key});

  @override
  State<ResourceListPage> createState() => _ResourceListPageState();
}

class _ResourceListPageState extends State<ResourceListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Resource> _resources = [];

  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  static const int _limit = 24;

  @override
  void initState() {
    super.initState();

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
      final newResources = await HttpRequests().fetchResources(page: _page, limit: _limit);

      setState(() {
        _resources.addAll(newResources);
        _page++;

        if (newResources.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      debugPrint('Ошибка загрузки ресурсов: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Доступные ресурсы", style: TxtStyles.h1.copyWith(color: blackC)),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              itemCount: _resources.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                //childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                if (index >= _resources.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final resource = _resources[index];
                return ResourceCard(resource: resource);
              },
            ),
          ),
        ],
      ),
    );
  }
}
