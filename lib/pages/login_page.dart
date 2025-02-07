import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tawhida_login/components/my_button.dart';
import 'package:tawhida_login/components/my_textfield.dart';
import 'package:tawhida_login/components/square_title.dart';
import 'package:tawhida_login/pages/register_page.dart';    

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key , required this.onTap });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {

    showDialog(
      context: context, 
      builder:(context){
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pop(context);
    }on FirebaseAuthException catch (e){
      Navigator.pop(context);
      //wrong email 
      if (e.code=='user-not-found'){
        //show error to user 
        wrongEmailMessage(); 

      } else if (e.code == 'wrong-password'){
        //show error to user
        wrongPasswordMessage();
      }
    }

   
  }
  //wrong email message popup
  void wrongEmailMessage(){
    showDialog(
      context: context,
      builder: (context){
        return const AlertDialog(
          title: Text('Incorrect Email '),
        );
      }
    );
  }
  void wrongPasswordMessage(){
    showDialog(
      context: context,
      builder: (context){
        return const AlertDialog(
          title: Text('Incorrect Password '),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
                  decoration: BoxDecoration(
                  image:DecorationImage(
                      image: AssetImage('lib/images/background.png'),
                      fit:BoxFit.cover,
                    ),
                  ), 

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
              
                  // logo
                  Positioned(
                        
                        
                        child: Padding(
                          padding: const EdgeInsets.all (8.0),
                          child: Image.asset(
                            'lib/images/logintaw.png',
                            width :150, 
                            height :150, 
                  
                          ),
                        ),
                  ),
              
                  const SizedBox(height: 30),
              
                  // welcome back, you've been missed!
                  Text(
                    'Welcome back you\'ve been missed!',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
              
                  const SizedBox(height: 25),
              
                  // username textfield
                  MyTextField(
                    controller: emailController,
                    hintText: 'Username',
                    obscureText: false,
                  ),
              
                  const SizedBox(height: 10),
              
                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
              
                  const SizedBox(height: 10),
              
                  // forgot password?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 25),
              
                  // sign in button
                  MyButton(
                    text: "Sign In ", 
                    onTap: signUserIn,
                  ),
              
                  const SizedBox(height: 50),
              
                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 50),
              
                  // google + apple sign in buttons
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      // google button
                      SquareTile(imagePath: 'lib/images/google.png'),
              
                      
              
                      
                    ],
                  ),
              
                  const SizedBox(height: 50),
              
                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        //onTap: widget.onTap ,
                        onTap: (){print('heree');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder:(context)=>RegisterPage(onTap: null),
                          ),


                        );},
                        child: const Text(
                          'Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
