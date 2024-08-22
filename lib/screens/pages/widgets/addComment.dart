import 'package:flutter/material.dart';

class CommentWidget extends StatefulWidget {
  final String? initialComment;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final Function(String) onCommentChanged;

  const CommentWidget({
    Key? key,
    this.initialComment,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    required this.onCommentChanged,
  }) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.initialComment ?? '';
    _commentController.addListener(() {
      widget.onCommentChanged(_commentController.text);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialComment != widget.initialComment) {
      _commentController.text = widget.initialComment ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a comment...',
            border: OutlineInputBorder(),
          ),
        ),
        if (widget.updatedAt != null && widget.updatedBy != null)
          Text(
            'Updated by ${widget.updatedBy} at ${widget.updatedAt}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        if (widget.createdAt != null && widget.createdBy != null)
          Text(
            'Created by ${widget.createdBy} at ${widget.createdAt}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}
