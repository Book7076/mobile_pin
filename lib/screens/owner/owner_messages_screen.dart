import 'package:flutter/material.dart';

const Color kOwnerPrimaryColor = Color(0xFF7C1431);

class OwnerMessagesScreen extends StatefulWidget {
  const OwnerMessagesScreen({super.key});

  @override
  State<OwnerMessagesScreen> createState() => _OwnerMessagesScreenState();
}

class _OwnerMessagesScreenState extends State<OwnerMessagesScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'customerName': 'คุณสมชาย (ลูกค้าประจำ)',
      'lastMessage': 'วันนี้ไก่ทอดซอสเกาหลีเผ็ดมากไหมครับ?',
      'time': '11:42 น.',
      'unread': 2,
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
    },
    {
      'customerName': 'คุณวิภาวรรณ',
      'lastMessage': 'สั่ง 3 กล่องเรียบร้อยแล้วนะคะ เดี๋ยวเข้าไปรับ',
      'time': '10:15 น.',
      'unread': 0,
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    },
    {
      'customerName': 'Rider LINE MAN',
      'lastMessage': 'ผมถึงหน้าร้านแล้วครับ ออเดอร์ #8841',
      'time': '09:30 น.',
      'unread': 1,
      'avatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80',
    },
    {
      'customerName': 'คุณณัฐพล',
      'lastMessage': 'ขอบคุณสำหรับไก่ทอดอร่อยมากครับ',
      'time': 'เมื่อวาน',
      'unread': 0,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    },
  ];

  void _openChatDialog(String customerName) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('แชทกับ $customerName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                child: const Text('สวัสดีครับ สอบถามเรื่องออเดอร์ครับ'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความตอบกลับ...',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: kOwnerPrimaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: kOwnerPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ข้อความและแชท',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final unread = chat['unread'] as int;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () => _openChatDialog(chat['customerName']),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(chat['avatar']),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: kOwnerPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      chat['customerName'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    chat['time'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  chat['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unread > 0 ? Colors.black87 : Colors.grey[600],
                    fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      ),
    );
  }
}
