import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crie sua Conta'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 40),

                // Campo de texto para o Nome
                TextField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de texto para o Email
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de texto para a Senha
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de texto para confirmar a senha
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão de Cadastrar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Lógica de cadastro aqui
                  },
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Botão para voltar ao login
                TextButton(
                  onPressed: () {
                    // Ação para voltar para a tela de login
                    Navigator.pop(context);
                  },
                  child: const Text('Já tem uma conta? Faça login'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}