import 'package:flutter/material.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/config/data.dart';
import 'package:klasio/presentation/providers/folder_notifier.dart';

class FolderModalContent extends StatefulWidget {
  final int? id;
  final FolderNotifier folderNotifier;

  const FolderModalContent({super.key, required this.folderNotifier, this.id});

  @override
  State<FolderModalContent> createState() => _FolderModalContentState();
}

class _FolderModalContentState extends State<FolderModalContent> {
  final nameController = TextEditingController();
  final ValueNotifier<bool> _isBusyNotifier = ValueNotifier<bool>(false);
  int selectedColorIndex = 0;
  int selectedIconIndex = 0;

  Future<void> loadFolderData(int id) async {
    final folder = await widget.folderNotifier.getById(id);
    if (folder != null && mounted) {
      setState(() {
        nameController.text = folder.name;
        selectedColorIndex = folder.indexColor;
        selectedIconIndex = folder.indexIcon;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.id != null) {
        loadFolderData(widget.id!);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    _isBusyNotifier.dispose();
    super.dispose();
  }

  Future<void> _submitFolder() async {
    final text = nameController.text.trim();
    if (text.isEmpty) return;
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;

    try {
      if (widget.id != null) {
        await widget.folderNotifier.updateFolder(
          widget.id!,
          text,
          selectedIconIndex,
          selectedColorIndex,
        );
      } else {
        await widget.folderNotifier.addFolder(
          text,
          selectedIconIndex,
          selectedColorIndex,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surface,
          content: Text(
            "Carpeta '$text' ${widget.id != null ? 'actualizada' : 'creada'} exitosamente.",
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _isBusyNotifier.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar carpeta: $e"),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isBusyNotifier,
      builder: (context, isBusy, child) {
        return AbsorbPointer(
          absorbing: isBusy,
          child: SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      widget.id != null
                          ? "Editar Carpeta de Materia"
                          : "Crear Carpeta de Materia",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.id != null
                          ? "Modifica el nombre, color o icono de tu materia."
                          : "Crea un espacio para agrupar todas las fotos y capturas de una clase.",
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      autofocus: widget.id == null,
                      decoration: InputDecoration(
                        hintText: "Ej. Matemáticas Discretas",
                        labelText: "Nombre de la materia",
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.class_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Color del folder:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: colorOptions.length,
                        itemBuilder: (context, index) {
                          final opt = colorOptions[index];
                          final isSelected = selectedColorIndex == index;
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColorIndex = colorOptions.indexOf(
                                    opt,
                                  );
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 44,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: opt.option,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: opt.option.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 22,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Icono del folder:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: iconOptions.length,
                        itemBuilder: (context, index) {
                          final opt = iconOptions[index];
                          final isSelected = selectedIconIndex == index;
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIconIndex = iconOptions.indexOf(opt);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  opt.option,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: 22,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isBusy ? null : _submitFolder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isBusy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.id != null
                                    ? "Actualizar Carpeta"
                                    : "Crear Carpeta",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
