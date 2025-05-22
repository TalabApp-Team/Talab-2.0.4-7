import 'dart:ui' as ui;

import 'package:Talab/app/app_theme.dart';
import 'package:Talab/data/cubits/company_cubit.dart';
import 'package:Talab/data/cubits/system/app_theme_cubit.dart';
import 'package:Talab/data/model/company.dart';
import 'package:Talab/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:Talab/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:Talab/ui/screens/widgets/custom_text_form_field.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  ContactUsState createState() => ContactUsState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(builder: (_) => const ContactUs());
  }
}

class ContactUsState extends State<ContactUs> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final companyCubit = context.read<CompanyCubit>();
      if (companyCubit.state is CompanyInitial || companyCubit.state is CompanyFetchFailure) {
        companyCubit.fetchCompany(context);
      }
    });
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF6B46C1),
        title: Text('Support', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0), // Increased padding for height
                child: ListTile(
                  leading: Icon(Icons.email, color: Color(0xFF6B46C1)),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _launchEmail('support@talab.qa', context),
                        child: Text('support@talab.qa', style: TextStyle(color: Colors.black87)),
                      ),
                      SizedBox(height: 12), // Space between entries
                      Text('Merchant', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _launchEmail('sellersupport@talab.qa', context),
                        child: Text('sellersupport@talab.qa', style: TextStyle(color: Colors.black87)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.phone, color: Color(0xFF6B46C1)),
                title: Text('Hotline', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('+974 7061 6051', style: TextStyle(color: Colors.black87)),
                trailing: GestureDetector(
                  onTap: () => _launchWhatsApp('+97470616051'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UiUtils.getSvg(
                        AppIcons.whatsappPng,
                        width: 20,
                        height: 20,
                        color: Color(0xFF6B46C1),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Chat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => _launchPhone('+97470616051', context),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.language, color: Color(0xFF6B46C1)),
                title: Text('Website', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('talab.qa', style: TextStyle(color: Colors.black87)),
                onTap: () => _launchURL('https://talab.qa', context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email, BuildContext context) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch email')));
    }
  }

  void _launchPhone(String phone, BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch phone')));
    }
  }

  void _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone?text=Hi');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch website')));
    }
  }
}

class EmailSendWidget extends StatefulWidget {
  final String email;

  const EmailSendWidget({Key? key, required this.email}) : super(key: key);

  @override
  State<EmailSendWidget> createState() => _EmailSendWidgetState();
}

class _EmailSendWidgetState extends State<EmailSendWidget> {
  final TextEditingController _subject = TextEditingController();
  late final TextEditingController _email = TextEditingController(text: widget.email);
  final TextEditingController _text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.0),
      body: Center(
        child: Container(
          clipBehavior: Clip.antiAlias,
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            boxShadow: context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? null
                : [
                    BoxShadow(
                      blurRadius: 3,
                      color: ui.Color.fromARGB(255, 201, 201, 201),
                    ),
                  ],
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.color.territoryColor.withOpacity(0.0),
                            shape: BoxShape.circle,
                          ),
                          width: 40,
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: Directionality(
                              textDirection: Directionality.of(context),
                              child: RotatedBox(
                                quarterTurns: Directionality.of(context) == TextDirection.rtl ? 2 : -4,
                                child: UiUtils.getSvg(AppIcons.arrowLeft),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomText("sendEmail".translate(context)),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    controller: _subject,
                    hintText: "subject".translate(context),
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    controller: _email,
                    isReadOnly: true,
                    hintText: "companyEmailLbl".translate(context),
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    controller: _text,
                    maxLine: 100,
                    hintText: "writeSomething".translate(context),
                    minLine: 5,
                  ),
                  const SizedBox(height: 15),
                  UiUtils.buildButton(
                    context,
                    onPressed: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: _email.text,
                        query: 'subject=${_subject.text}&body=${_text.text}',
                      );
                      await launchUrl(emailUri);
                    },
                    height: 50,
                    buttonTitle: "sendEmail".translate(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
