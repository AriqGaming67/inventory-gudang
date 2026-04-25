import 'package:flutter/material.dart';

class AnimatedElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final double elevation;
  final bool isLoading;

  const AnimatedElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor = const Color(0xFF2563EB),
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.elevation = 0,
    this.isLoading = false,
  });

  @override
  State<AnimatedElevatedButton> createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _shadowAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _shadowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius as BorderRadius,
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withValues(alpha: 0.4),
                  blurRadius: _shadowAnimation.value,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: ElevatedButton.icon(
          onPressed: widget.isLoading
              ? null
              : () {
                  _controller.forward().then((_) {
                    _controller.reverse();
                  });
                  widget.onPressed();
                },
          icon: widget.icon != null
              ? Icon(widget.icon, size: 18)
              : const SizedBox.shrink(),
          label: widget.isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.foregroundColor,
                    ),
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            padding: widget.padding,
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius as BorderRadius,
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

class AnimatedOutlinedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color borderColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  const AnimatedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.borderColor = const Color(0xFF2563EB),
    this.textColor = const Color(0xFF2563EB),
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  State<AnimatedOutlinedButton> createState() => _AnimatedOutlinedButtonState();
}

class _AnimatedOutlinedButtonState extends State<AnimatedOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: widget.borderColor,
      end: widget.borderColor.withValues(alpha: 0.7),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return OutlinedButton.icon(
            onPressed: () {
              _controller.forward().then((_) {
                _controller.reverse();
              });
              widget.onPressed();
            },
            icon: widget.icon != null
                ? Icon(widget.icon, size: 18, color: _colorAnimation.value)
                : const SizedBox.shrink(),
            label: Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _colorAnimation.value,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: widget.padding,
              shape: RoundedRectangleBorder(
                borderRadius: widget.borderRadius as BorderRadius,
                side: BorderSide(color: _colorAnimation.value ?? Colors.blue),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final String? tooltip;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = const Color(0xFF2563EB),
    this.foregroundColor = Colors.white,
    this.tooltip,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotateAnimation,
        child: FloatingActionButton(
          onPressed: () {
            _controller.forward().then((_) {
              _controller.reverse();
            });
            widget.onPressed();
          },
          tooltip: widget.tooltip,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          elevation: 4,
          child: Icon(widget.icon),
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String? tooltip;

  const AnimatedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor = const Color(0xFF2563EB),
    this.iconSize = 24,
    this.tooltip,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        onPressed: () {
          _controller.forward().then((_) {
            _controller.reverse();
          });
          widget.onPressed();
        },
        icon: Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
        tooltip: widget.tooltip,
      ),
    );
  }
}
