import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landmark_manager/models/landmark.dart';
import 'package:landmark_manager/providers/landmark_provider.dart';
import 'package:landmark_manager/services/image_service.dart';
import 'package:landmark_manager/utils/constants.dart';

class FormScreen extends StatefulWidget {
  final int? landmarkId;
  final Landmark? landmark;

  const FormScreen({
    Key? key,
    this.landmarkId,
    this.landmark,
  }) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isEditing = false;
  bool _isLoading = false;
  
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _checkEditingState();
  }

  void _checkEditingState() {
    if (widget.landmark != null) {
      _initFormData(widget.landmark!);
    } else if (widget.landmarkId != null) {
      // Find landmark by ID from provider
      // Use addPostFrameCallback to safely access context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<LandmarkProvider>(context, listen: false);
        final landmark = provider.getLandmarkById(widget.landmarkId!);
        if (landmark != null) {
          setState(() {
            _initFormData(landmark);
          });
        }
      });
    }
  }

  void _initFormData(Landmark landmark) {
    _isEditing = true;
    _titleController.text = landmark.title;
    _latController.text = landmark.lat.toString();
    _lonController.text = landmark.lon.toString();
    _currentImageUrl = landmark.image;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool fromCamera) async {
    final file = fromCamera 
        ? await _imageService.takePhoto() 
        : await _imageService.pickImage();
        
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<LandmarkProvider>(context, listen: false);
      final location = await provider.getCurrentLocation();
      
      if (location.lat != null && location.lon != null) {
        _latController.text = location.lat.toString();
        _lonController.text = location.lon.toString();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check if image is provided for new landmark
    if (!_isEditing && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<LandmarkProvider>(context, listen: false);
      final title = _titleController.text;
      final lat = double.parse(_latController.text);
      final lon = double.parse(_lonController.text);
      
      bool success;
      
      if (_isEditing) {
        final id = widget.landmarkId ?? widget.landmark!.id!;
        success = await provider.updateLandmark(
          id: id,
          title: title,
          lat: lat,
          lon: lon,
          image: _selectedImage,
        );
      } else {
        success = await provider.createLandmark(
          title: title,
          lat: lat,
          lon: lon,
          image: _selectedImage!,
        );
      }
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_isEditing ? 'Landmark updated' : 'Landmark created')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.error ?? 'An error occurred')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Landmark' : 'Add Landmark'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image selection
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take Photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(true);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from Gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _currentImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(child: Icon(Icons.broken_image, size: 50)),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Tap to add photo', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Landmark Title',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Coordinates fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lonController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          tooltip: 'Use current location',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isEditing ? 'Update Landmark' : 'Create Landmark',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
