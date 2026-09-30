import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double textMultiplier;
  static late double imageSizeMultiplier;
  static late double heightMultiplier;
  static late double widthMultiplier;
  static late bool isPortrait;
  static late bool isTablet;

  static bool isInitialized = false;

  static void init(BuildContext context) {
    if (isInitialized) return;

    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    isPortrait = _mediaQueryData.orientation == Orientation.portrait;

    // Check if device is a tablet based on shortest side
    isTablet = _mediaQueryData.size.shortestSide >= 600;

    // If in landscape mode, swap width and height calculations
    if (!isPortrait) {
      screenWidth = _mediaQueryData.size.height;
      screenHeight = _mediaQueryData.size.width;
    }

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    textMultiplier = blockSizeVertical;
    imageSizeMultiplier = blockSizeHorizontal;
    heightMultiplier = blockSizeVertical;
    widthMultiplier = blockSizeHorizontal;

    isInitialized = true;
  }

  // Width based on percentage of screen width
  static double w(double width) {
    return width * widthMultiplier;
  }

  // Height based on percentage of screen height
  static double h(double height) {
    return height * heightMultiplier;
  }

  // Text size based on percentage of screen height
  static double sp(double fontSize) {
    return fontSize * textMultiplier;
  }

  // Safe area width based on percentage
  static double sw(double width) {
    return width * safeBlockHorizontal;
  }

  // Safe area height based on percentage
  static double sh(double height) {
    return height * safeBlockVertical;
  }

  // Get actual pixel value for width
  static double getActualWidth(double width) {
    return width * screenWidth / 100;
  }

  // Get actual pixel value for height
  static double getActualHeight(double height) {
    return height * screenHeight / 100;
  }

  // Responsive value based on screen size
  static double getResponsiveValue({
    required double forShortScreen,
    required double forTallScreen,
    double breakpoint = 700,
  }) {
    return screenHeight < breakpoint ? forShortScreen : forTallScreen;
  }

  // Get responsive font size with min and max constraints
  static double getResponsiveFontSize(
    double fontSize, {
    double? min,
    double? max,
  }) {
    double scaledSize = sp(fontSize);
    if (min != null && scaledSize < min) {
      return min;
    }
    if (max != null && scaledSize > max) {
      return max;
    }
    return scaledSize;
  }

  // Check if current device is tablet
  static bool get isTabletDevice => isTablet;

  // Check if current orientation is portrait
  static bool get isPortraitMode => isPortrait;

  // Get current orientation
  static Orientation get orientation => _mediaQueryData.orientation;
}
