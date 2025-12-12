import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:landmark_manager/models/landmark.dart';
import 'package:landmark_manager/views/map/map_viewmodel.dart';
import 'package:landmark_manager/views/form/form_screen.dart';
import 'package:landmark_manager/routes.dart';
import 'package:landmark_manager/utils/constants.dart';
import 'package:landmark_manager/widgets/landmark_bottom_sheet.dart';
import 'package:landmark_manager/providers/landmark_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    // Initialize view model with provider from context in didChangeDependencies or build
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      final landmarkProvider = Provider.of<LandmarkProvider>(context, listen: false);
      _viewModel = MapViewModel(landmarkProvider);
    }
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, _) {
          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: viewModel.initialCameraPosition,
                onMapCreated: viewModel.onMapCreated,
                markers: viewModel.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onTap: (_) => viewModel.clearSelectedLandmark(),
              ),

              // Current location button
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'location',
                  onPressed: viewModel.moveToCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),

              // Add new landmark button
              Positioned(
                bottom: 80,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'add',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add_location_alt),
                ),
              ),

              // Loading indicator
              if (viewModel.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Selected landmark bottom sheet
              if (viewModel.selectedLandmark != null)
                LandmarkBottomSheet(
                  landmark: viewModel.selectedLandmark!,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(
                          landmark: viewModel.selectedLandmark!,
                        ),
                      ),
                    );
                  },
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Landmark'),
                        content: const Text(
                            'Are you sure you want to delete this landmark?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final success = await viewModel
                          .deleteLandmark(viewModel.selectedLandmark!);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Landmark deleted successfully'),
                          ),
                        );
                      }
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
