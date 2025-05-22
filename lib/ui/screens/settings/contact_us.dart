
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
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: "contactUs".translate(context),
        showBackButton: true,
      ),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is CompanyFetchProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CompanyFetchSuccess) {
            final companyData = state.companyData;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "howCanWeHelp".translate(context),
                    color: context.color.textColorDark,
                    fontSize: context.font.larger,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 10),
                  CustomText(
                    "itLooksLikeYouHasError".translate(context),
                    fontSize: context.font.small,
                    color: context.color.textLightColor,
                  ),
                  const SizedBox(height: 15),
                  customTile(
                    context,
                    title: "callBtnLbl".translate(context),
                    svgImagePath: AppIcons.call,
                    onTap: () => _showCallDialog(context, companyData),
                    showWhatsApp: true, // Enable WhatsApp icon
                    onWhatsAppTap: () async {
                      final whatsappNumber = '6238440943';
                      final message = Uri.encodeComponent("Hi");
                      final url = Uri.parse("https://wa.me/$whatsappNumber?text=$message");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  customTile(
                    context,
                    title: "companyEmailLbl".translate(context),
                    svgImagePath: AppIcons.message,
                    onTap: () => _showEmailDialog(context, companyData.companyEmail ?? ''),
                  ),
                ],
              ),
            );
          } else if (state is CompanyFetchFailure) {
            return Center(child: CustomText(state.errmsg));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void _showCallDialog(BuildContext context, Company companyData) {
    final number1 = companyData.companyTel1;
    final number2 = companyData.companyTel2;

    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: "chooseNumber".translate(context),
        showCancelButton: false,
        barrierDismissible: true,
        acceptTextColor: context.color.buttonColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              title: CustomText(
                number1.toString(),
                textAlign: TextAlign.center,
              ),
              onTap: () async {
                await launchUrl(Uri.parse("tel:$number1"));
              },
            ),
            if (number2 != null)
              ListTile(
                title: CustomText(
                  number2.toString(),
                  textAlign: TextAlign.center,
                ),
                onTap: () async {
                  await launchUrl(Uri.parse("tel:$number2"));
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEmailDialog(BuildContext context, String email) {
    Navigator.push(
      context,
      BlurredRouter(
        builder: (context) => EmailSendWidget(email: email),
      ),
    );
  }

  Widget customTile(
    BuildContext context, {
    required String title,
    required String svgImagePath,
    bool? isSwitchBox,
    Function(dynamic value)? onTapSwitch,
    dynamic switchValue,
    required VoidCallback onTap,
    bool showWhatsApp = false, // New parameter to show WhatsApp icon
    VoidCallback? onWhatsAppTap, // Callback for WhatsApp tap
  }) {
    return Row(
      children: [
        // Left side: Icon and Title (for the main tap action)
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.color.territoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: UiUtils.getSvg(
                      svgImagePath,
                      color: context.color.territoryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 25),
                CustomText(
                  title,
                  fontWeight: FontWeight.w700,
                  color: context.color.textColorDark,
                ),
              ],
            ),
          ),
        ),
        // Right side: Either WhatsApp icon or default arrow/switch
        if (showWhatsApp && onWhatsAppTap != null)
          GestureDetector(
            onTap: onWhatsAppTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UiUtils.getSvg(
                  AppIcons.whatsappPng, // Use WhatsApp icon
                  width: 20,
                  height: 20,
                  color: context.color.territoryColor,
                ),
                const SizedBox(width: 5),
                CustomText(
                  "Chat", // Label as per the previous implementation
                  fontWeight: FontWeight.w700,
                  color: context.color.textColorDark,
                ),
              ],
            ),
          )
        else if (isSwitchBox != true)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: context.color.borderColor, width: 1.5),
              color: context.color.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FittedBox(
              fit: BoxFit.none,
              child: SizedBox(
                width: 8,
                height: 15,
                child: UiUtils.getSvg(
                  AppIcons.arrowRight,
                  color: context.color.textColorDark,
                ),
              ),
            ),
          ),
        if (isSwitchBox ?? false)
          Switch(
            value: switchValue ?? false,
            onChanged: (value) {
              onTapSwitch?.call(value);
            },
          ),
      ],
    );
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