// perfil do usuário.
import 'package:chat_app/src/provaders/profile_provider.dart';
import 'package:chat_app/src/widgets/custom_avatar.dart';
import 'package:chat_app/src/widgets/custom_button.dart';
import 'package:chat_app/src/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late ProfileProvider _provider;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _provider = Provider.of<ProfileProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadUserProfile().then((_) {
        // Preenche o controller com o nome carregado
        if (_provider.user != null) {
          _nameController.text = _provider.user!.name;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final success = await _provider.saveProfile(_nameController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Perfil salvo com sucesso!' : 'Erro ao salvar perfil.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.pop(context); // Volta para a lista de chats
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.user == null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.user == null) {
            return const Center(child: Text('Não foi possível carregar o perfil.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      // A imagem (do provider ou a nova imagem escolhida)
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        backgroundImage: provider.pickedImage != null
                            ? FileImage(provider.pickedImage!)
                            : null,
                        child: provider.pickedImage == null
                            ? CustomAvatar(
                                name: provider.user!.name,
                                imageUrl: provider.user!.avatarUrl,
                                radius: 60,
                              )
                            : null,
                      ),
                      // Botão de editar
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 22,
                          child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 22),
                            onPressed: provider.pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Campo de Nome
                CustomInput(
                  label: 'Nome',
                  hint: 'Seu nome completo',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),

                // Campo de Email (desabilitado)
                TextFormField(
                  initialValue: provider.user!.email,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 32),

                // Botão Salvar
                CustomButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonText: provider.isLoading ? 'Salvando...' : 'Salvar',
                  buttonAction: provider.isLoading ? null : _save,
                ),

                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
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