

import 'package:flutter/material.dart';
import 'package:interview/comment/entity/QuestionEntity.dart';

import '../components/recording_bottom_sheet.dart';
import 'RecordPage.dart';


class QuestionCard extends StatelessWidget {
  // final Question question;
  final int id;
  final String text;
  final bool isAnswered;

  const QuestionCard({super.key, required this.text, this.isAnswered = false, required this.id});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(
          color: isDark ? Color(0xFF374151) : Color(0xFFE5E7EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1A365D).withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 左侧回答状态指示条
          if (isAnswered)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),

          // 内容区域
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 问题文本
                Text(
                  text!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Color(0xFF1F2937),
                  ),
                ),

                SizedBox(height: 12),

                // 语音按钮与状态
                Row(
                  children: [
                    // 语音按钮
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.mic, size: 28),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.all(12),
                        ),
                        onPressed: () => showVoiceRecordingSheet(context,text)
                      ),
                    ),

                    SizedBox(width: 8),

                    // 回答状态标签
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAnswered
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isAnswered ? "已回答" : "待练习",
                        style: TextStyle(
                          color: isAnswered ? Colors.green : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


