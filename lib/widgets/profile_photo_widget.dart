import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:breathe_flow/services/auth_service.dart';
import 'package:breathe_flow/constants/app_colors.dart';
import 'package:breathe_flow/constants/app_typography.dart';

class ProfilePhotoWidget extends StatefulWidget {
  final String? initialPhotoURL;
  final double size;
  final VoidCallback? onPhotoUpdated;
  final bool isEditable;

  const ProfilePhotoWidget({
    super.key,
    this.initialPhotoURL,
    this.size = 100,
    this.onPhotoUpdated,
    this.isEditable = true,
  });

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  
  String? _currentPhotoURL;
  bool _isUploading = false;
  File? _imageFile;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _currentPhotoURL = widget.initialPhotoURL;
  }

  @override
  void didUpdateWidget(ProfilePhotoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPhotoURL != widget.initialPhotoURL) {
      setState(() {
        _currentPhotoURL = widget.initialPhotoURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ana profil fotoğrafı container
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildProfileImage(),
          ),
        ),

        // Upload progress indicator
        if (_isUploading)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
            ),
                       child: const Center(
             child: CircularProgressIndicator(
               color: AppColors.primaryAccent,
               strokeWidth: 3,
             ),
           ),
          ),

        // Edit button
        if (widget.isEditable && !_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showPhotoOptions,
              child: Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _currentPhotoURL != null ? Icons.edit : Icons.add,
                  color: Colors.white,
                  size: widget.size * 0.15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage() {
    // Web için local image
    if (kIsWeb && _webImage != null) {
      return Image.memory(
        _webImage!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    }

    // Mobile için local image
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    }

    // Network image
    if (_currentPhotoURL != null && _currentPhotoURL!.isNotEmpty) {
      return Image.network(
        _currentPhotoURL!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: widget.size,
            height: widget.size,
            color: AppColors.surface,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    // Varsayılan avatar
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
                     colors: [
             AppColors.primary.withOpacity(0.8),
             AppColors.primaryAccent.withOpacity(0.8),
           ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: widget.size * 0.5,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
                         Text(
               'Profil Fotoğrafı',
               style: AppTypography.headlineSmall.copyWith(
                 color: AppColors.textPrimary,
               ),
             ),
            const SizedBox(height: 32),

            // Kameradan çek
            _buildOptionTile(
              icon: Icons.camera_alt,
              title: 'Kameradan Çek',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),

            const SizedBox(height: 16),

            // Galeriden seç
            _buildOptionTile(
              icon: Icons.photo_library,
              title: 'Galeriden Seç',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),

            if (_currentPhotoURL != null) ...[
              const SizedBox(height: 16),
              // Fotoğrafı sil
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Fotoğrafı Sil',
                onTap: () {
                  Navigator.pop(context);
                  _deletePhoto();
                },
                isDestructive: true,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: isDestructive ? Colors.red : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: AppColors.background.withOpacity(0.5),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploading = true;
        });

        if (kIsWeb) {
          // Web için
          _webImage = await pickedFile.readAsBytes();
          await _uploadPhoto();
        } else {
          // Mobile için
          _imageFile = File(pickedFile.path);
          await _uploadPhoto();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Fotoğraf seçilirken bir hata oluştu: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadPhoto() async {
    try {
      String? downloadURL;

      if (kIsWeb && _webImage != null) {
        downloadURL = await _authService.uploadProfilePhotoBytes(_webImage!);
      } else if (_imageFile != null) {
        downloadURL = await _authService.uploadProfilePhoto(_imageFile!);
      }

      if (downloadURL != null) {
        setState(() {
          _currentPhotoURL = downloadURL;
          _imageFile = null;
          _webImage = null;
        });

        widget.onPhotoUpdated?.call();
        _showSuccessSnackBar('Profil fotoğrafınız başarıyla güncellendi!');
      } else {
        _showErrorSnackBar('Fotoğraf yüklenemedi, lütfen tekrar deneyin.');
      }
    } catch (e) {
      _showErrorSnackBar('Fotoğraf yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> _deletePhoto() async {
    try {
      setState(() {
        _isUploading = true;
      });

      bool deleted = await _authService.deleteProfilePhoto();
      
      if (deleted) {
        setState(() {
          _currentPhotoURL = null;
          _imageFile = null;
          _webImage = null;
        });

        widget.onPhotoUpdated?.call();
        _showSuccessSnackBar('Profil fotoğrafınız silindi.');
      } else {
        _showErrorSnackBar('Fotoğraf silinemedi, lütfen tekrar deneyin.');
      }
    } catch (e) {
      _showErrorSnackBar('Fotoğraf silinirken bir hata oluştu: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
} 