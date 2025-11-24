import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  Future<void> _showEditDialog(BuildContext context, String uid, String currentBio, String currentPhoto) async {
    final bioController = TextEditingController(text: currentBio);
    XFile? pickedImage;
    File? imageFile;
    String photoPreview = currentPhoto;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // preview atual ou selecionada
                if ((pickedImage != null) || photoPreview.isNotEmpty)
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: pickedImage != null
                            ? FileImage(File(pickedImage!.path))
                            : NetworkImage(photoPreview) as ImageProvider,
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
                    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
                    if (p != null) {
                      setState(() {
                        pickedImage = p;
                        imageFile = File(p.path);
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Ao salvar, a foto será enviada e usada como imagem de perfil.',
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
                  String? uploadedUrl = currentPhoto;
                  if (imageFile != null) {
                    final ref = FirebaseStorage.instance.ref().child('user_photos/$uid.jpg');
                    final uploadTask = await ref.putFile(imageFile!);
                    uploadedUrl = await ref.getDownloadURL();
                  }
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'bio': bio,
                    'photoUrl': uploadedUrl ?? '',
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
              // abrir diálogo de edição com dados atuais (lidos do Firestore para garantir sincronização)
              final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              final data = doc.data() ?? {};
              final currentBio = data['bio'] as String? ?? '';
              final currentPhoto = data['photoUrl'] as String? ?? '';
              await _showEditDialog(context, uid, currentBio, currentPhoto);
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
                            : const AssetImage('lib/repositories/images/user.png'),
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
