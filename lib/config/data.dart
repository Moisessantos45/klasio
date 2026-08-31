import 'package:flutter/material.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/domain/entities/color.dart';
import 'package:klasio/domain/entities/icon.dart';

final List<ColorOption> colorOptions = [
  ColorOption(
    option: AppColors.folderBlue,
    bgOption: AppColors.folderBlueLight,
  ),
  ColorOption(
    option: AppColors.folderGreen,
    bgOption: AppColors.folderGreenLight,
  ),
  ColorOption(
    option: AppColors.folderOrange,
    bgOption: AppColors.folderOrangeLight,
  ),
  ColorOption(
    option: AppColors.folderPurple,
    bgOption: AppColors.folderPurpleLight,
  ),
  ColorOption(
    option: AppColors.folderPink,
    bgOption: AppColors.folderPinkLight,
  ),
  ColorOption(
    option: AppColors.folderYellow,
    bgOption: AppColors.folderYellowLight,
  ),
];

final List<IconOption> iconOptions = [
  IconOption(option: Icons.folder),
  IconOption(option: Icons.cloud),
  IconOption(option: Icons.calendar_today),
  IconOption(option: Icons.book),
  IconOption(option: Icons.bookmark),
  IconOption(option: Icons.money),
  IconOption(option: Icons.school),
  IconOption(option: Icons.work),
  IconOption(option: Icons.star),
  IconOption(option: Icons.email),
  IconOption(option: Icons.message),
  IconOption(option: Icons.call),
  IconOption(option: Icons.video_call),
  IconOption(option: Icons.photo),
  IconOption(option: Icons.camera),
  IconOption(option: Icons.videocam),
  IconOption(option: Icons.music_note),
  IconOption(option: Icons.headset),
  IconOption(option: Icons.shopping_cart),
  IconOption(option: Icons.local_offer),
  IconOption(option: Icons.restaurant),
  IconOption(option: Icons.wallet),
];
