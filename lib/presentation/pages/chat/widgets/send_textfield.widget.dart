import 'package:flutter/material.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';

class SendTextfieldW extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final void Function(String) onMore;
  final String? hintText;
  final void Function(String)? onFieldSubmitted;

  const SendTextfieldW({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onMore,
    required this.onFieldSubmitted,
    this.hintText,
  });

  @override
  State<SendTextfieldW> createState() => _SendTextfieldWState();
}

class _SendTextfieldWState extends State<SendTextfieldW> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      setState(() {}); // we rebuild to update icon
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        LNDTextField.regular(
          controller: widget.controller,
          hintText: widget.hintText ?? "Message",
          textInputAction: TextInputAction.send,
          onFieldSubmitted: widget.onFieldSubmitted,
          suffixWidget: const SizedBox(width: 48),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInBack,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child:
                  hasText
                      ? Container(
                        key: const ValueKey("send_icon"),
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: widget.onSend,
                        ),
                      )
                      : LNDShow.popupMenuIcon(
                        icon: Icons.menu,
                        items: [
                          LNDMenuItem<String>(
                            label: 'Camera',
                            icon: Icons.camera_alt_rounded,
                            value: 'camera',
                            onTap: (val) {
                              widget.onMore(val);
                            },
                          ),
                          LNDMenuItem<String>(
                            label: 'Gallery',
                            icon: Icons.photo_album_rounded,
                            value: 'gallery',
                            onTap: (val) {
                              widget.onMore(val);
                            },
                          ),
                          // LNDMenuItem<String>(
                          //   label: 'Saved Banks',
                          //   icon: Icons.storage_rounded,
                          //   value: 'banks',
                          //   onTap: (val) {
                          //     widget.onMore(val);
                          //   },
                          // ),
                        ],
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
