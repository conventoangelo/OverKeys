import 'package:flutter/material.dart';

class MouseScreen extends StatelessWidget {
  final Map<int, bool>
      buttonStates; // Map of button codes to their pressed states
  final Color mouseColorPressed;
  final Color mouseColorNotPressed;
  final double mouseWidth;
  final double mouseHeight;
  final double mouseBorderRadius;
  final Color markerColor;
  final Color markerColorNotPressed;
  final double markerWidth;
  final double markerHeight;
  final double markerBorderRadius;
  final double markerOffset;
  final bool hasSideButtons;

  const MouseScreen({
    super.key,
    required this.buttonStates,
    required this.mouseColorPressed,
    required this.mouseColorNotPressed,
    required this.mouseWidth,
    required this.mouseHeight,
    required this.mouseBorderRadius,
    required this.markerColor,
    required this.markerColorNotPressed,
    required this.markerWidth,
    required this.markerHeight,
    required this.markerBorderRadius,
    required this.markerOffset,
    required this.hasSideButtons,
  });

  @override
  Widget build(BuildContext context) {
    bool isLeftPressed = buttonStates[0] ?? false; // Left button
    bool isRightPressed = buttonStates[1] ?? false; // Right button
    bool isMiddlePressed = buttonStates[2] ?? false; // Middle/wheel button
    bool isBackPressed = buttonStates[3] ?? false; // Back button
    bool isForwardPressed = buttonStates[4] ?? false; // Forward button

    return Center(
      child: SizedBox(
        width: mouseWidth *
            (hasSideButtons
                ? 1.2
                : 1.0), // Make room for side buttons only if needed
        height: mouseHeight,
        child: Stack(
          alignment: Alignment.centerRight, // Align main body to the right
          clipBehavior: Clip.none, // Allow children to overflow
          children: [
            // Main mouse body
            Container(
              width: mouseWidth,
              height: mouseHeight,
              decoration: BoxDecoration(
                color: mouseColorNotPressed,
                borderRadius: BorderRadius.circular(mouseBorderRadius),
              ),
            ),
            // Left button area
            Positioned(
              top: 0,
              right: mouseWidth * 0.5,
              child: Container(
                width: mouseWidth * 0.5,
                height: mouseHeight * 0.35,
                decoration: BoxDecoration(
                  color:
                      isLeftPressed ? mouseColorPressed : mouseColorNotPressed,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(mouseBorderRadius),
                  ),
                ),
              ),
            ),
            // Right button area
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: mouseWidth * 0.5,
                height: mouseHeight * 0.35,
                decoration: BoxDecoration(
                  color:
                      isRightPressed ? mouseColorPressed : mouseColorNotPressed,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(mouseBorderRadius),
                  ),
                ),
              ),
            ),
            // Horizontal button divider line
            Positioned(
              top: mouseHeight * 0.35,
              right: 0,
              child: Container(
                width: mouseWidth,
                height: 2,
                color: markerColorNotPressed,
              ),
            ),
            // Vertical button divider line
            Positioned(
              top: 0,
              right: mouseWidth * 0.5,
              child: Container(
                width: 2,
                height: mouseHeight * 0.35,
                color: (isLeftPressed && isRightPressed)
                    ? markerColor
                    : markerColorNotPressed,
              ),
            ),
            // Scroll wheel area
            Positioned(
              top: mouseHeight * 0.1,
              right: mouseWidth * 0.425,
              child: Container(
                width: mouseWidth * 0.15,
                height: mouseHeight * 0.2,
                decoration: BoxDecoration(
                  color: isMiddlePressed
                      ? mouseColorPressed
                      : mouseColorNotPressed,
                  border: Border.all(
                    color:
                        isMiddlePressed ? markerColor : markerColorNotPressed,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(markerBorderRadius),
                ),
              ),
            ),
            // Side buttons container (Back/Forward) - only if hasSideButtons is true
            if (hasSideButtons)
              Positioned(
                right: mouseWidth * 1.03, // Position outside the main body
                top: mouseHeight * 0.35,
                child: Container(
                  width: mouseWidth * 0.1,
                  height: mouseHeight * 0.26,
                  decoration: BoxDecoration(
                    color: mouseColorNotPressed,
                    borderRadius:
                        BorderRadius.circular(mouseBorderRadius * 0.3),
                  ),
                  child: Stack(
                    children: [
                      // Forward button area
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: mouseHeight * 0.13,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isForwardPressed
                                ? mouseColorPressed
                                : mouseColorNotPressed,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(mouseBorderRadius * 0.3)),
                          ),
                        ),
                      ),
                      // Back button area
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: mouseHeight * 0.13,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBackPressed
                                ? mouseColorPressed
                                : mouseColorNotPressed,
                            borderRadius: BorderRadius.vertical(
                                bottom:
                                    Radius.circular(mouseBorderRadius * 0.3)),
                          ),
                        ),
                      ),
                      // Horizontal separator
                      Positioned(
                        top: mouseHeight * 0.13,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: (isBackPressed && isForwardPressed)
                              ? markerColor
                              : markerColorNotPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
