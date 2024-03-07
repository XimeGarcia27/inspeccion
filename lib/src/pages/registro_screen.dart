import 'package:app_inspections/providers/login_form_provider.dart';
import 'package:app_inspections/services/services.dart';
import 'package:app_inspections/src/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 280), //para mover el widget
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), // Agregar márgenes horizontales
                child: SizedBox(
                  height: 700,
                  child: CardContainer(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          'Crear cuenta',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        const SizedBox(height: 70),
                        ChangeNotifierProvider(
                          create: (_) => LoginFormProvider(),
                          child: _LoginForm(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 70),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'login');
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                    Colors.indigo.withOpacity(0.1),
                  ),
                  shape: MaterialStateProperty.all(const StadiumBorder()),
                ),
                child: const Text(
                  '¿Ya tienes una nueva cuenta?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Form(
      key: loginForm.formkey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          const SizedBox(height: 30), //separar renglones

          TextFormField(
            // Configuraciones del cuadro de texto
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => loginForm.email = value,
            validator: (value) {
              String pattern = r'^[a-zA-Z0-9_.+-]+@gmail\.com$';
              RegExp regExp = RegExp(pattern);

              return regExp.hasMatch(value ?? '')
                  ? null
                  : 'Por favor, introduce un correo electrónico válido de Gmail';
            },
            // Decoración del cuadro de texto
            decoration: InputDecoration(
              hintText: 'example@gmail.com',
              labelText: 'Correo electrónico',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              // Cambiar el color del borde del cuadro de texto
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color.fromRGBO(
                        169, 27, 96, 1)), // Cambia el color del borde aquí
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color.fromRGBO(
                        169, 27, 96, 1)), // Cambia el color del borde aquí
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),

          const SizedBox(height: 30), //separar renglones

          TextFormField(
            // Configuraciones del cuadro de texto
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            obscureText: true, //para ocultar la contraseña
            onChanged: (value) => loginForm.password = value,
            validator: (value) {
              return (value != null && value.length >= 6)
                  ? null
                  : 'La contraseña debe de ser de 6 caracteres';
            },
            // Decoración del cuadro de texto
            decoration: InputDecoration(
              hintText: '***********',
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outlined),
              // Cambiar el color del borde del cuadro de texto
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromRGBO(
                      169, 27, 96, 1), // Cambia el color del borde aquí
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromRGBO(
                      169, 27, 96, 1), // Cambia el color del borde aquí
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),

          const SizedBox(height: 90),

          MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: const Color.fromRGBO(6, 6, 68, 1),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  child: Text(
                    loginForm.isLoading ? 'Espere' : 'Ingresar',
                    style: TextStyle(color: Colors.white),
                  )),
              onPressed: loginForm.isLoading
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      final authService =
                          Provider.of<AuthService>(context, listen: false);

                      if (!loginForm.isValidForm()) return;

                      loginForm.isLoading = true;

                      final String? errorMessage = await authService.createUser(
                          loginForm.email, loginForm.password);
                      if (errorMessage == null) {
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(
                            context, 'login'); //navegar a otra pantalla
                      } else {
                        print(errorMessage);
                        loginForm.isLoading = false;
                      }
                    })
        ],
      ),
    );
  }
}
