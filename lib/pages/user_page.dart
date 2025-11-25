import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  Future<void> _showEditDialog(
    BuildContext context,
    String uid,
    String currentBio,
    String currentPhotoUrl,
    String currentPhotoBase64,
  ) async {
    final bioController = TextEditingController(text: currentBio);
    XFile? pickedImage;
    File? imageFile;
    String photoPreviewUrl = currentPhotoUrl;
    String photoPreviewBase64 = currentPhotoBase64;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // preview: selecionada > base64 atual > url atual
                if (pickedImage != null ||
                    photoPreviewBase64.isNotEmpty ||
                    photoPreviewUrl.isNotEmpty)
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: pickedImage != null
                            ? FileImage(File(pickedImage!.path)) // <-- changed: use ! to satisfy analyzer
                            : (photoPreviewBase64.isNotEmpty
                                ? MemoryImage(base64Decode(photoPreviewBase64))
                                    as ImageProvider
                                : NetworkImage(photoPreviewUrl) as ImageProvider),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Biografia'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Escolher da galeria'),
                  onPressed: () async {
                    final p = await ImagePicker()
                        .pickImage(source: ImageSource.gallery, imageQuality: 75);
                    if (p != null) {
                      setState(() {
                        pickedImage = p;
                        imageFile = File(p.path);
                        // quando escolher, preferimos mostrar o arquivo local
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Ao salvar, a foto será armazenada em nossos servidores!',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final bio = bioController.text.trim();
                try {
                  String uploadedBase64 = currentPhotoBase64;
                  String clearUrl = currentPhotoUrl;
                  if (imageFile != null) {
                    final bytes = await imageFile!.readAsBytes();
                    uploadedBase64 = base64Encode(bytes);
                    clearUrl = '';
                  }
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'bio': bio,
                    'photoBase64': uploadedBase64,
                    'photoUrl': clearUrl,
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = context.watch<UserRepository>();
    final User? localUser = userRepository.currentUser;

    if (localUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('Nenhum usuário logado.')),
      );
    }

    final uid = localUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<UserRepository>().logout();
            },
            tooltip: 'Sair',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // ler dados atuais (url + base64) do Firestore
              final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              final data = doc.data() ?? {};
              final currentBio = data['bio'] as String? ?? '';
              final currentPhotoUrl = data['photoUrl'] as String? ?? '';
              final currentPhotoBase64 = data['photoBase64'] as String? ?? '';
              await _showEditDialog(context, uid, currentBio, currentPhotoUrl, currentPhotoBase64);
            },
            tooltip: 'Editar Perfil',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return const Center(child: Text('Erro ao carregar perfil.'));
          }

          final doc = snapshot.data!;
          final user = User.fromFirestore(doc);

          return Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: user.photoUrl.isNotEmpty
                            ? NetworkImage(user.photoUrl) as ImageProvider
                            : (user.photoBase64.isNotEmpty
                                ? MemoryImage(base64Decode(user.photoBase64))
                                : const AssetImage('lib/repositories/images/user.png')) as ImageProvider,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 380,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10, top: 7),
                          child: Text("Bio", style: TextStyle(fontSize: 22)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            right: 10,
                            bottom: 10,
                            left: 10,
                          ),
                          child: Text(
                            user.bio.isNotEmpty
                                ? user.bio
                                : 'Ainda não adicionou uma biografia.',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
