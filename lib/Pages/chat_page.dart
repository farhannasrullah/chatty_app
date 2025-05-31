import 'package:chatty_app/Components/chat_bubble.dart'; // Sesuaikan path jika perlu
import 'package:chatty_app/Components/my_textfield.dart'; // Sesuaikan path jika perlu
import 'package:chatty_app/services/auth/auth_service.dart'; // Sesuaikan path jika perlu
import 'package:chatty_app/services/chat/chat_service.dart'; // Sesuaikan path jika perlu
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController =
      ScrollController(); // Untuk auto-scroll

  Stream<QuerySnapshot>? _messageStream;

  @override
  void initState() {
    super.initState();
    // Inisialisasi stream pesan di sini agar stabil
    final currentUser =
        _authService
            .getCurentUser(); // Hati-hati dengan getCurentUser(), pastikan namanya benar
    if (currentUser != null) {
      print(
        "ChatPage initState: Mengambil pesan untuk receiverID: ${widget.receiverID} dan senderID: ${currentUser.uid}",
      );
      _messageStream = _chatService.getMessages(
        widget.receiverID,
        currentUser.uid,
      );
    } else {
      print(
        "ChatPage initState: Error! Pengguna saat ini null, tidak bisa mengambil pesan.",
      );
      // Pertimbangkan untuk menampilkan pesan error atau navigasi kembali jika user null
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Jangan lupa dispose scroll controller
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text;
      // Kosongkan controller SEBELUM mengirim, agar UI terasa lebih responsif
      _messageController.clear();

      try {
        await _chatService.sendMessage(widget.receiverID, messageText);
        print("Pesan terkirim: $messageText");
        _scrollToBottom(); // Scroll ke bawah setelah pesan terkirim
      } catch (e) {
        print("Error saat mengirim pesan: $e");
        // Tampilkan pesan error ke pengguna jika perlu
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mengirim pesan: $e")));
      }
    }
  }

  // Fungsi untuk scroll otomatis ke pesan terakhir
  void _scrollToBottom() {
    // Pastikan _scrollController sudah terpasang ke ListView dan ada item
    if (_scrollController.hasClients) {
      // Memberi sedikit jeda agar item baru sempat ter-render sebelum scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.transparent, // Sesuai kode Anda
        foregroundColor: Colors.grey, // Sesuai kode Anda
        elevation: 0, // Sesuai kode Anda
      ),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildUserInput()],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messageStream == null) {
      // Ini terjadi jika currentUser null saat initState
      return const Center(
        child: Text(
          "Tidak dapat memuat pesan. Pengguna tidak terautentikasi atau stream error.",
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _messageStream,
      builder: (context, snapshot) {
        // Logging untuk status StreamBuilder
        print("StreamBuilder State: ${snapshot.connectionState}");
        if (snapshot.hasError) {
          print("StreamBuilder Error: ${snapshot.error}");
          return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Memuat pesan..."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("StreamBuilder: Tidak ada data pesan.");
          return const Center(
            child: Text("Belum ada pesan. Ayo mulai percakapan!"),
          );
        }

        // Jika ada data, scroll ke bawah setelah UI di-render
        // Ini juga membantu jika ada pesan baru masuk saat user sedang melihat chat lama
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        print("StreamBuilder: Menerima ${snapshot.data!.docs.length} pesan.");
        return ListView.builder(
          controller: _scrollController,
          reverse:
              false, // Set false jika ingin urutan normal (pesan lama di atas)
          // dan dikombinasikan dengan scroll ke bawah.
          // Jika true, list akan mulai dari bawah.
          padding: const EdgeInsets.all(8.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // Jika reverse: true, akses dokumen secara terbalik agar pesan baru di bawah
            // final doc = snapshot.data!.docs[snapshot.data!.docs.length - 1 - index]; // Jika reverse true
            final doc = snapshot.data!.docs[index]; // Jika reverse false
            return _buildMessageItem(doc);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    print("_buildMessageItem dipanggil untuk Dokumen ID: ${document.id}");
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data == null) {
      print("Data untuk dokumen ${document.id} adalah null.");
      return const SizedBox.shrink(); // Jangan tampilkan apa-apa jika data null
    }

    // Ambil ID pengguna saat ini dengan aman
    final currentUser = _authService.getCurentUser();
    if (currentUser == null) {
      print(
        "_buildMessageItem: currentUser is null, tidak bisa menentukan isCurrentUser.",
      );
      // Atau tampilkan pesan dengan style netral jika user tidak terdeteksi
      return ChatBubble(
        message: data['message'] as String? ?? "[Pesan tidak valid]",
        isCurrentUser: false,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }

    // Tentukan apakah pesan ini dari pengguna saat ini
    bool isCurrentUser = (data['senderID'] == currentUser.uid);

    print(
      "Pesan: ${data['message']}, Dari User Saat Ini: $isCurrentUser, senderID di data: ${data['senderID']}, UID saat ini: ${currentUser.uid}",
    );

    return Container(
      // Penyelarasan bubble chat (kanan untuk pengguna, kiri untuk orang lain)
      // Container luar ini di-align oleh ListView item, jadi alignment di ChatBubble mungkin lebih tepat
      // atau gunakan Row dengan MainAxisAlignment jika diperlukan
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatBubble(
        message:
            data['message'] as String? ??
            "[Pesan Kosong]", // Fallback jika message null
        isCurrentUser: isCurrentUser,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      // Padding agar input field tidak tertutup keyboard
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            8.0, // Dinamis dengan keyboard
        left: 8.0,
        right: 8.0,
        top: 8.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              controller: _messageController,
              hintText: "Ketik pesan...",
              obscureText: false, // Pastikan ini false untuk input chat
              // Tambahkan onSubmitted jika ingin kirim dengan tombol enter di keyboard fisik
              // onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Gunakan warna tema
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ), // Ganti ikon jika mau
            ),
          ),
        ],
      ),
    );
  }
}
