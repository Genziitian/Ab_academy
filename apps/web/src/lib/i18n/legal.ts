import "server-only";
import { CONTACT } from "@/lib/landing";
import type { Locale } from "./config";

// The four legal pages in English and Hindi. Server-only, so this text is
// never sent to the browser as part of a script bundle.

/** A paragraph is a string; a bulleted list is an array of strings. */
export type LegalSection = { heading?: string; body: (string | string[])[] };
export type LegalDoc = { title: string; description: string; intro: string; sections: LegalSection[] };
export type LegalKey = "privacy" | "terms" | "refund" | "deletion";

const address = CONTACT.address.join(", ");
const email = CONTACT.email;

const en: Record<LegalKey, LegalDoc> = {
  privacy: {
    title: "Privacy policy",
    description: "What AB Academy collects, why, who it is shared with, and how to delete it.",
    intro:
      "AB Academy (Akhand Bharat Academy) runs the website abacademy.in and the AB Academy app. This policy explains what we collect, why, who we share it with, and the choices you have. We do not sell your data and we do not show ads.",
    sections: [
      {
        heading: "What we collect",
        body: [
          [
            "Account details: your mobile number (for OTP sign-in), or your name, email address and profile photo from Google if you sign in with Google.",
            "Study details you give us: class, stream, medium and, if you add it, your school.",
            "Purchases: which course you bought, the amount, and the payment status and reference from Razorpay. Your card, UPI or bank details go to Razorpay, never to us.",
            "Learning activity: lectures and notes you open, doubts and comments you post under lectures, lecture ratings, support tickets, and notification and pop-up history.",
            "Device details for the app: a push-notification token and the app version, used to deliver notifications and fix problems.",
          ],
        ],
      },
      {
        heading: "Why we use it",
        body: [
          [
            "To sign you in and keep your account secure.",
            "To give you the courses you bought and remember where you left off.",
            "To answer your doubts and support requests.",
            "To send notices about your classes, such as a new lecture or a doubt session.",
            "To protect our course content: your phone number or student code is shown faintly on videos and notes as a watermark.",
            "To keep transaction records that Indian tax law requires.",
          ],
        ],
      },
      {
        heading: "Who we share it with",
        body: [
          "Only with the services that run AB Academy, and only what each one needs:",
          [
            "Supabase: hosts our database, sign-in and files.",
            "Razorpay: processes payments.",
            "Google: Google sign-in, Firebase Cloud Messaging for notifications, Google Drive for hosting notes files, and YouTube, which streams our recorded lectures inside the app and website.",
            "Our teachers and support staff see your name, class and the doubts or tickets you send them.",
          ],
          "We share data with authorities only when Indian law requires it.",
        ],
      },
      {
        heading: "Students under 18",
        body: [
          "Our courses are for Class 11 and 12 students, most of whom are under 18. A parent or guardian should create the account or agree to the student using it, and should make any purchase. We do not use children's data for advertising, tracking or profiling.",
        ],
      },
      {
        heading: "How long we keep it",
        body: [
          "We keep your account data while your account is open. When you delete your account, your personal data and activity are erased within 3 days of your request. Orders and payment records are kept, separated from your name, for as long as Indian tax law requires (typically up to 8 years).",
        ],
      },
      {
        heading: "How we protect it",
        body: [
          "Data travels over encrypted connections. Each student can read only their own records, enforced in the database itself. Paid lectures and notes open only for enrolled students, and the app blocks screenshots on lecture and notes screens.",
        ],
      },
      {
        heading: "Your rights",
        body: [
          "You can see and correct your details in your profile. You can ask us for a copy of your data, to correct it, or to delete your data or your whole account — see Data & account deletion. You can withdraw consent at any time by deleting your account.",
        ],
      },
      {
        heading: "Grievances and contact",
        body: [
          `Write to ${email}, or to AB Academy, ${address}. We reply within 7 days. If we change this policy we will update the date above and tell you in the app for significant changes.`,
        ],
      },
    ],
  },

  terms: {
    title: "Terms & conditions",
    description: "The rules for using AB Academy's website, app and courses.",
    intro:
      "These terms apply when you use the AB Academy website or app, or buy a course. By creating an account you agree to them. If you are under 18, a parent or guardian must agree to them for you.",
    sections: [
      {
        heading: "Your account",
        body: [
          [
            "Sign in with your own mobile number or Google account and keep it to yourself. One account is for one student.",
            "Give correct details. You are responsible for what happens on your account.",
            "You can delete your account at any time from the app (More → Delete account or data) or on the website.",
          ],
        ],
      },
      {
        heading: "Courses and access",
        body: [
          "Each course gives you access to its recorded classes, live doubt sessions, notes and practice questions for the period shown on the course page. Class dates, lectures and teachers may change; we will tell you in the app when they do.",
          "We teach to the Bihar Board syllabus and pattern, but we cannot promise any particular marks or result.",
        ],
      },
      {
        heading: "Prices and payment",
        body: [
          "Prices are in Indian rupees and shown before you pay. Payments are processed by Razorpay. A course unlocks on your account once the payment is confirmed. Refunds follow our Refund policy.",
        ],
      },
      {
        heading: "Using our content",
        body: [
          "Lectures, notes and questions are for your personal study only. You must not:",
          [
            "record, screenshot, download, copy or share lectures or notes;",
            "share your account, or sell or give away access;",
            "try to get around the app's protections or reach lecture videos outside the app or website.",
          ],
          "Videos and notes carry your watermark. If we find content shared, we may suspend the account without a refund.",
        ],
      },
      {
        heading: "Doubts, comments and messages",
        body: [
          "Be respectful. Do not post anything abusive, hateful, sexual, misleading, or anyone's personal information, and do not advertise or spam. We may remove posts and suspend accounts that break these rules. To report a post or a user, use Help & support in the app or write to us.",
        ],
      },
      {
        heading: "Our responsibility",
        body: [
          "We work to keep the service available and accurate but cannot promise it will always be uninterrupted or error-free. To the extent the law allows, our liability for any claim about a course is limited to the amount you paid for that course.",
        ],
      },
      {
        heading: "Law and disputes",
        body: [
          `These terms are governed by the laws of India, and the courts of Bihar have jurisdiction. Before going to court, please write to us at ${email} so we can try to resolve it.`,
        ],
      },
    ],
  },

  refund: {
    title: "Refund policy",
    description: "When and how AB Academy refunds a course purchase.",
    intro:
      "We want you to buy a course only when you are sure it suits you, so every course has a free demo. If something still goes wrong, here is how refunds work.",
    sections: [
      {
        heading: "When you can get a refund",
        body: [
          [
            "Within 7 days of purchase, if you have watched no more than 3 lectures of the course.",
            "If you were charged twice for the same course — the extra payment is refunded in full.",
            "If you paid but the course did not unlock and we cannot fix it within 2 working days.",
          ],
        ],
      },
      {
        heading: "When refunds are not given",
        body: [
          [
            "After 7 days from purchase, or after more than 3 lectures have been watched.",
            "If the account was suspended for sharing content or breaking our Terms.",
          ],
        ],
      },
      {
        heading: "How to ask",
        body: [
          `Raise a ticket in the app (Help & support → Payment) or write to ${email} with your registered phone number or email and the order ID. We reply within 2 working days.`,
        ],
      },
      {
        heading: "How you are paid back",
        body: [
          "Approved refunds go back to the original payment method through Razorpay. Banks usually take 5–7 working days to show the money. If a payment failed but money left your account, your bank normally reverses it automatically within 7 working days.",
        ],
      },
      {
        heading: "Grievances",
        body: [
          `If you are not satisfied with a refund decision, write to ${email} with “Grievance” in the subject, or to AB Academy, ${address}.`,
        ],
      },
    ],
  },

  deletion: {
    title: "Data & account deletion",
    description: "Ask AB Academy to delete your data or your whole account.",
    intro:
      "You can ask us to delete your personal data, or your whole AB Academy account, at any time — from the app (More → Delete account or data) or on this page. We complete every request within 3 days.",
    sections: [
      {
        heading: "What “Delete my data” removes",
        body: [
          [
            "Your name, profile photo and school.",
            "Doubts and comments you posted, lecture ratings and support tickets.",
            "Notification and pop-up history, and the app's push-notification tokens.",
          ],
          "Your account, sign-in and the courses you bought stay, so you can keep studying.",
        ],
      },
      {
        heading: "What “Delete my account” removes",
        body: [
          "Everything above, plus your sign-in, profile, class details, enrolments and progress. The account cannot be restored, and access to courses you bought ends.",
        ],
      },
      {
        heading: "What we keep, and why",
        body: [
          "Orders and payment records are kept, separated from your name, for as long as Indian tax law requires (typically up to 8 years). A short record that you asked for deletion is kept, with your contact details masked.",
        ],
      },
      {
        heading: "Can't sign in?",
        body: [
          `Email ${email} from the email address on your account, or include the mobile number you sign in with, and write “Delete my account” or “Delete my data”. We verify it is you and complete the request within 3 days.`,
        ],
      },
    ],
  },
};

const hi: Record<LegalKey, LegalDoc> = {
  privacy: {
    title: "गोपनीयता नीति",
    description: "AB अकादमी क्या जानकारी लेती है, क्यों, किसके साथ साझा करती है और उसे कैसे हटाएँ।",
    intro:
      "AB अकादमी (अखंड भारत अकादमी) वेबसाइट abacademy.in और AB अकादमी ऐप चलाती है। यह नीति बताती है कि हम क्या जानकारी लेते हैं, क्यों लेते हैं, किसके साथ साझा करते हैं और आपके पास क्या विकल्प हैं। हम आपका डेटा बेचते नहीं हैं और विज्ञापन नहीं दिखाते।",
    sections: [
      {
        heading: "हम क्या जानकारी लेते हैं",
        body: [
          [
            "अकाउंट की जानकारी: आपका मोबाइल नंबर (OTP से साइन इन के लिए), या Google से साइन इन करने पर आपका नाम, ईमेल और प्रोफ़ाइल फ़ोटो।",
            "पढ़ाई की जानकारी जो आप देते हैं: कक्षा, स्ट्रीम, माध्यम और, अगर जोड़ें तो, आपका स्कूल।",
            "ख़रीदारी: आपने कौन-सा कोर्स ख़रीदा, कितनी राशि, और Razorpay से पेमेंट की स्थिति और रेफ़रेंस। आपके कार्ड, UPI या बैंक की जानकारी सीधे Razorpay को जाती है, हमें कभी नहीं।",
            "पढ़ाई की गतिविधि: आपने कौन-से लेक्चर और नोट्स खोले, लेक्चर के नीचे पूछे गए डाउट और कमेंट, लेक्चर रेटिंग, सपोर्ट टिकट, और नोटिफ़िकेशन व पॉप-अप की हिस्ट्री।",
            "ऐप के लिए डिवाइस की जानकारी: पुश-नोटिफ़िकेशन टोकन और ऐप का वर्ज़न, ताकि नोटिफ़िकेशन भेजे जा सकें और समस्याएँ ठीक की जा सकें।",
          ],
        ],
      },
      {
        heading: "हम इसका उपयोग क्यों करते हैं",
        body: [
          [
            "आपको साइन इन कराने और अकाउंट सुरक्षित रखने के लिए।",
            "आपके ख़रीदे कोर्स देने और यह याद रखने के लिए कि आपने कहाँ तक पढ़ा।",
            "आपके डाउट और सहायता अनुरोधों का जवाब देने के लिए।",
            "आपकी क्लास से जुड़ी सूचनाएँ भेजने के लिए, जैसे नया लेक्चर या डाउट सेशन।",
            "कोर्स सामग्री की सुरक्षा के लिए: वीडियो और नोट्स पर आपका फ़ोन नंबर या स्टूडेंट कोड हल्के वॉटरमार्क के रूप में दिखता है।",
            "भारतीय कर क़ानून के अनुसार लेन-देन का रिकॉर्ड रखने के लिए।",
          ],
        ],
      },
      {
        heading: "हम किसके साथ साझा करते हैं",
        body: [
          "सिर्फ़ उन सेवाओं के साथ जिनसे AB अकादमी चलती है, और हर सेवा को सिर्फ़ उतना जितना ज़रूरी हो:",
          [
            "Supabase: हमारा डेटाबेस, साइन इन और फ़ाइलें रखता है।",
            "Razorpay: पेमेंट प्रोसेस करता है।",
            "Google: Google साइन इन, नोटिफ़िकेशन के लिए Firebase Cloud Messaging, नोट्स फ़ाइलों के लिए Google Drive, और YouTube, जिससे हमारे रिकॉर्डेड लेक्चर ऐप और वेबसाइट में चलते हैं।",
            "हमारे शिक्षक और सहायता टीम आपका नाम, कक्षा और आपके भेजे गए डाउट या टिकट देखते हैं।",
          ],
          "हम डेटा सरकारी अधिकारियों के साथ तभी साझा करते हैं जब भारतीय क़ानून इसकी माँग करे।",
        ],
      },
      {
        heading: "18 वर्ष से कम उम्र के छात्र",
        body: [
          "हमारे कोर्स कक्षा 11 और 12 के छात्रों के लिए हैं, जिनमें से ज़्यादातर 18 वर्ष से कम हैं। अकाउंट माता-पिता या अभिभावक को बनाना चाहिए या छात्र के उपयोग के लिए सहमति देनी चाहिए, और कोई भी ख़रीदारी उन्हीं को करनी चाहिए। हम बच्चों के डेटा का उपयोग विज्ञापन, ट्रैकिंग या प्रोफ़ाइलिंग के लिए नहीं करते।",
        ],
      },
      {
        heading: "हम इसे कितने समय तक रखते हैं",
        body: [
          "जब तक आपका अकाउंट खुला है, हम अकाउंट का डेटा रखते हैं। अकाउंट हटाने पर आपका निजी डेटा और गतिविधि अनुरोध के 3 दिन के अंदर मिटा दी जाती है। ऑर्डर और पेमेंट के रिकॉर्ड, आपके नाम से अलग करके, उतने समय तक रखे जाते हैं जितना भारतीय कर क़ानून माँगता है (आमतौर पर 8 साल तक)।",
        ],
      },
      {
        heading: "हम इसे कैसे सुरक्षित रखते हैं",
        body: [
          "डेटा एन्क्रिप्टेड कनेक्शन से जाता है। हर छात्र सिर्फ़ अपने रिकॉर्ड देख सकता है, और यह डेटाबेस के स्तर पर लागू है। पेड लेक्चर और नोट्स सिर्फ़ दाख़िले वाले छात्रों के लिए खुलते हैं, और ऐप लेक्चर व नोट्स की स्क्रीन पर स्क्रीनशॉट रोकता है।",
        ],
      },
      {
        heading: "आपके अधिकार",
        body: [
          "आप अपनी प्रोफ़ाइल में अपनी जानकारी देख और सुधार सकते हैं। आप हमसे अपने डेटा की कॉपी माँग सकते हैं, उसे सुधरवा सकते हैं, या अपना डेटा या पूरा अकाउंट हटवा सकते हैं — देखें डेटा और अकाउंट हटाना। अकाउंट हटाकर आप कभी भी अपनी सहमति वापस ले सकते हैं।",
        ],
      },
      {
        heading: "शिकायत और संपर्क",
        body: [
          `${email} पर लिखें, या AB अकादमी, ${address} पर पत्र भेजें। हम 7 दिन में जवाब देते हैं। नीति बदलने पर हम ऊपर की तारीख़ बदलेंगे, और बड़े बदलाव की सूचना ऐप में देंगे।`,
        ],
      },
    ],
  },

  terms: {
    title: "नियम और शर्तें",
    description: "AB अकादमी की वेबसाइट, ऐप और कोर्स इस्तेमाल करने के नियम।",
    intro:
      "ये शर्तें तब लागू होती हैं जब आप AB अकादमी की वेबसाइट या ऐप इस्तेमाल करते हैं, या कोई कोर्स ख़रीदते हैं। अकाउंट बनाकर आप इनसे सहमत होते हैं। अगर आपकी उम्र 18 वर्ष से कम है, तो आपके माता-पिता या अभिभावक को आपकी ओर से सहमति देनी होगी।",
    sections: [
      {
        heading: "आपका अकाउंट",
        body: [
          [
            "अपने ही मोबाइल नंबर या Google अकाउंट से साइन इन करें और इसे किसी से साझा न करें। एक अकाउंट एक छात्र के लिए है।",
            "सही जानकारी दें। आपके अकाउंट पर जो होता है, उसकी ज़िम्मेदारी आपकी है।",
            "आप कभी भी ऐप (और → अकाउंट या डेटा हटाएँ) या वेबसाइट से अपना अकाउंट हटा सकते हैं।",
          ],
        ],
      },
      {
        heading: "कोर्स और एक्सेस",
        body: [
          "हर कोर्स में, कोर्स पेज पर बताई गई अवधि तक, उसकी रिकॉर्डेड क्लास, लाइव डाउट सेशन, नोट्स और अभ्यास के सवाल मिलते हैं। क्लास की तारीख़, लेक्चर और शिक्षक बदल सकते हैं; बदलने पर हम ऐप में बताएँगे।",
          "हम बिहार बोर्ड के सिलेबस और पैटर्न के अनुसार पढ़ाते हैं, लेकिन किसी ख़ास अंक या रिज़ल्ट का वादा नहीं कर सकते।",
        ],
      },
      {
        heading: "क़ीमत और पेमेंट",
        body: [
          "क़ीमतें भारतीय रुपये में हैं और पेमेंट से पहले दिखाई जाती हैं। पेमेंट Razorpay से होता है। पेमेंट की पुष्टि होते ही कोर्स आपके अकाउंट में खुल जाता है। रिफ़ंड हमारी रिफ़ंड नीति के अनुसार होते हैं।",
        ],
      },
      {
        heading: "हमारी सामग्री का उपयोग",
        body: [
          "लेक्चर, नोट्स और सवाल सिर्फ़ आपकी निजी पढ़ाई के लिए हैं। आप ये नहीं कर सकते:",
          [
            "लेक्चर या नोट्स रिकॉर्ड करना, स्क्रीनशॉट लेना, डाउनलोड करना, कॉपी करना या साझा करना;",
            "अपना अकाउंट साझा करना, या एक्सेस बेचना या किसी को देना;",
            "ऐप की सुरक्षा को तोड़ने की कोशिश करना या ऐप/वेबसाइट के बाहर लेक्चर वीडियो तक पहुँचना।",
          ],
          "वीडियो और नोट्स पर आपका वॉटरमार्क होता है। सामग्री साझा होने का पता चलने पर हम बिना रिफ़ंड के अकाउंट निलंबित कर सकते हैं।",
        ],
      },
      {
        heading: "डाउट, कमेंट और संदेश",
        body: [
          "सम्मान से बात करें। अपमानजनक, नफ़रत भरी, अश्लील, भ्रामक या किसी की निजी जानकारी वाली कोई बात न लिखें, और विज्ञापन या स्पैम न करें। इन नियमों को तोड़ने वाले पोस्ट हम हटा सकते हैं और अकाउंट निलंबित कर सकते हैं। किसी पोस्ट या यूज़र की शिकायत के लिए ऐप में मदद और सहायता का उपयोग करें या हमें लिखें।",
        ],
      },
      {
        heading: "हमारी ज़िम्मेदारी",
        body: [
          "हम सेवा को उपलब्ध और सही रखने की पूरी कोशिश करते हैं, लेकिन यह वादा नहीं कर सकते कि यह हमेशा बिना रुकावट या बिना ग़लती के चलेगी। क़ानून जहाँ तक अनुमति देता है, किसी कोर्स से जुड़े किसी भी दावे में हमारी ज़िम्मेदारी उस कोर्स के लिए आपके द्वारा दी गई राशि तक सीमित है।",
        ],
      },
      {
        heading: "क़ानून और विवाद",
        body: [
          `ये शर्तें भारत के क़ानूनों के अधीन हैं, और बिहार की अदालतों का क्षेत्राधिकार है। अदालत जाने से पहले कृपया ${email} पर हमें लिखें, ताकि हम मामला सुलझाने की कोशिश कर सकें।`,
        ],
      },
    ],
  },

  refund: {
    title: "रिफ़ंड नीति",
    description: "AB अकादमी कब और कैसे कोर्स का पैसा लौटाती है।",
    intro:
      "हम चाहते हैं कि आप कोर्स तभी ख़रीदें जब आपको यक़ीन हो कि यह आपके लिए सही है, इसलिए हर कोर्स का मुफ़्त डेमो है। फिर भी कुछ गड़बड़ हो, तो रिफ़ंड ऐसे होता है।",
    sections: [
      {
        heading: "रिफ़ंड कब मिलता है",
        body: [
          [
            "ख़रीद के 7 दिन के अंदर, अगर आपने कोर्स के 3 से ज़्यादा लेक्चर नहीं देखे हैं।",
            "अगर एक ही कोर्स के लिए दो बार पैसे कटे — अतिरिक्त पेमेंट पूरा लौटाया जाएगा।",
            "अगर पेमेंट के बाद कोर्स नहीं खुला और हम 2 कामकाजी दिनों में इसे ठीक नहीं कर पाए।",
          ],
        ],
      },
      {
        heading: "रिफ़ंड कब नहीं मिलता",
        body: [
          [
            "ख़रीद के 7 दिन बाद, या 3 से ज़्यादा लेक्चर देख लेने के बाद।",
            "अगर सामग्री साझा करने या हमारे नियम तोड़ने पर अकाउंट निलंबित हुआ हो।",
          ],
        ],
      },
      {
        heading: "कैसे माँगें",
        body: [
          `ऐप में टिकट बनाएँ (मदद और सहायता → पेमेंट) या अपने रजिस्टर्ड फ़ोन नंबर या ईमेल और ऑर्डर ID के साथ ${email} पर लिखें। हम 2 कामकाजी दिनों में जवाब देते हैं।`,
        ],
      },
      {
        heading: "पैसा कैसे वापस आता है",
        body: [
          "मंज़ूर रिफ़ंड Razorpay के ज़रिए उसी तरीक़े में वापस जाता है जिससे पेमेंट हुआ था। बैंक में पैसा दिखने में आमतौर पर 5–7 कामकाजी दिन लगते हैं। अगर पेमेंट फ़ेल हुआ पर पैसा कट गया, तो आपका बैंक आमतौर पर 7 कामकाजी दिनों में उसे अपने-आप लौटा देता है।",
        ],
      },
      {
        heading: "शिकायत",
        body: [
          `अगर आप रिफ़ंड के फ़ैसले से संतुष्ट नहीं हैं, तो विषय में “Grievance” लिखकर ${email} पर लिखें, या AB अकादमी, ${address} पर पत्र भेजें।`,
        ],
      },
    ],
  },

  deletion: {
    title: "डेटा और अकाउंट हटाना",
    description: "AB अकादमी से अपना डेटा या पूरा अकाउंट हटवाएँ।",
    intro:
      "आप कभी भी अपना निजी डेटा, या अपना पूरा AB अकादमी अकाउंट, हटाने के लिए कह सकते हैं — ऐप से (और → अकाउंट या डेटा हटाएँ) या इसी पेज से। हम हर अनुरोध 3 दिन में पूरा करते हैं।",
    sections: [
      {
        heading: "“मेरा डेटा हटाएँ” से क्या हटता है",
        body: [
          [
            "आपका नाम, प्रोफ़ाइल फ़ोटो और स्कूल।",
            "आपके पूछे गए डाउट और कमेंट, लेक्चर रेटिंग और सपोर्ट टिकट।",
            "नोटिफ़िकेशन और पॉप-अप की हिस्ट्री, और ऐप के पुश-नोटिफ़िकेशन टोकन।",
          ],
          "आपका अकाउंट, साइन इन और ख़रीदे गए कोर्स बने रहते हैं, ताकि आप पढ़ाई जारी रख सकें।",
        ],
      },
      {
        heading: "“मेरा अकाउंट हटाएँ” से क्या हटता है",
        body: [
          "ऊपर का सब कुछ, साथ में आपका साइन इन, प्रोफ़ाइल, कक्षा की जानकारी, दाख़िले और प्रगति। अकाउंट वापस नहीं आ सकता, और ख़रीदे गए कोर्स का एक्सेस ख़त्म हो जाता है।",
        ],
      },
      {
        heading: "हम क्या रखते हैं, और क्यों",
        body: [
          "ऑर्डर और पेमेंट के रिकॉर्ड, आपके नाम से अलग करके, उतने समय तक रखे जाते हैं जितना भारतीय कर क़ानून माँगता है (आमतौर पर 8 साल तक)। आपने हटाने का अनुरोध किया था, इसका एक छोटा रिकॉर्ड आपकी संपर्क जानकारी छिपाकर रखा जाता है।",
        ],
      },
      {
        heading: "साइन इन नहीं हो पा रहा?",
        body: [
          `अपने अकाउंट वाले ईमेल से ${email} पर लिखें, या जिस मोबाइल नंबर से साइन इन करते हैं वह लिखें, और साथ में “मेरा अकाउंट हटाएँ” या “मेरा डेटा हटाएँ” लिखें। हम पुष्टि करेंगे कि यह आप ही हैं और 3 दिन में अनुरोध पूरा करेंगे।`,
        ],
      },
    ],
  },
};

export function legalDoc(key: LegalKey, locale: Locale): LegalDoc {
  return (locale === "hi" ? hi : en)[key];
}

/** Shown above Hindi legal text: the English version governs. */
export const HINDI_LEGAL_NOTE =
  "यह हिंदी अनुवाद आपकी सुविधा के लिए है। किसी भी अंतर की स्थिति में अंग्रेज़ी संस्करण मान्य होगा।";

export const LEGAL_UPDATED = new Date("2026-11-03T00:00:00+05:30");
