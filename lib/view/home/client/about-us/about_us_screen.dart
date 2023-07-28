import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Pet Buddy Veterinary Clinic:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'At Pet Buddy Veterinary Clinic, we understand the unique bond between pets and their owners, especially when it comes to our beloved feline and canine companions. As a dedicated veterinary clinic, we cater specifically to the healthcare needs of cats and dogs, ensuring they receive the highest quality care and attention they deserve.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Our Passion for Pets:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'At the core of Pet Buddy Veterinary Clinic is our unwavering passion for animals. Our team of experienced and compassionate veterinarians, technicians, and support staff share a common love for pets and are committed to providing exceptional veterinary care. We believe that every animal deserves to live a happy, healthy life, and we strive to make a positive impact on the well-being of each and every pet that walks through our doors.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Comprehensive Veterinary Services:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Pet Buddy Veterinary Clinic offers a comprehensive range of veterinary services tailored specifically to meet the needs of cats and dogs. From preventive care and vaccinations to surgical procedures and emergency services, we provide a wide array of medical treatments to ensure the optimal health and longevity of your furry friends. Our modern facility is equipped with state-of-the-art diagnostic tools and equipment, enabling us to deliver accurate diagnoses and effective treatments.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Fear-Free Environment:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'We understand that visiting the veterinarian can be stressful for pets, so we\'ve designed our clinic to create a fear-free environment. Our dedicated staff employs gentle handling techniques and uses positive reinforcement to help reduce anxiety and make each visit as comfortable as possible. By prioritizing your pet\'s emotional well-being, we aim to build trust and foster a positive relationship that extends beyond our clinic walls.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Personalized Care and Education:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'At Pet Buddy Veterinary Clinic, we believe in the importance of personalized care. We take the time to listen to your concerns, answer your questions, and develop customized treatment plans tailored to your pet\'s unique needs. We strongly believe that educating pet owners is essential for maintaining their pet\'s health, so we strive to provide clear and comprehensive explanations of diagnoses, treatment options, and preventive measures.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'At Pet Buddy Veterinary Clinic, we are dedicated to being the trusted partner in your pet\'s healthcare journey. When you choose us, you can rest assured that your furry friend will receive the highest standard of veterinary care in a warm and welcoming environment. We look forward to welcoming you and your pet to our clinic and becoming your trusted "buddy" in your pet\'s well-being.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
