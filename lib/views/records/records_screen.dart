import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:landmark_manager/providers/landmark_provider.dart';
import 'package:landmark_manager/models/landmark.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:landmark_manager/routes.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh landmarks when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LandmarkProvider>(context, listen: false).loadLandmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmark Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete All',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete All Landmarks'),
                  content: const Text(
                      'Are you sure you want to delete ALL landmarks? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await Provider.of<LandmarkProvider>(context, listen: false)
                    .deleteAllLandmarks();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All landmarks deleted locally')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Consumer<LandmarkProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.landmarks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.landmarks.isEmpty) {
            return const Center(
              child: Text('No landmarks found. Add one!'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadLandmarks(),
            child: ListView.builder(
              itemCount: provider.landmarks.length,
              itemBuilder: (context, index) {
                final landmark = provider.landmarks[index];
                return Dismissible(
                  key: Key(landmark.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Landmark'),
                        content: const Text('Are you sure you want to delete this landmark?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    final landmarkId = landmark.id!;
                    
                    // Call provider to delete
                    await provider.deleteLandmark(landmarkId);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted Landmark ID: $landmarkId')),
                      );
                    }
                  },
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: landmark.image != null && landmark.image!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: landmark.image!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            )
                          : const Icon(Icons.image),
                    ),
                    title: Text(landmark.title),
                    // Displaying ID here so you can identify it
                    subtitle: Text('ID: ${landmark.id} | ${landmark.lat.toStringAsFixed(4)}, ${landmark.lon.toStringAsFixed(4)}'),
                    onTap: () {
                      context.push('${AppRoutes.editLandmark}/${landmark.id}');
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
