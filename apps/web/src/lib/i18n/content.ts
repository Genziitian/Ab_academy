// Course content that changes with the language: chapter names in Hindi
// (Bihar Board Hindi-medium wording) and course titles for the known courses.

import { SYLLABUS, subjectKey, type SubjectKey } from "@/lib/landing";
import type { Locale } from "./config";
import { dictionaries } from "./dictionaries";

const SYLLABUS_HI: Record<SubjectKey, string[]> = {
  Physics: [
    "वैद्युत आवेश तथा क्षेत्र",
    "स्थिरवैद्युत विभव तथा धारिता",
    "विद्युत धारा",
    "गतिमान आवेश और चुंबकत्व",
    "चुंबकत्व एवं द्रव्य",
    "वैद्युतचुंबकीय प्रेरण",
    "प्रत्यावर्ती धारा",
    "वैद्युतचुंबकीय तरंगें",
    "किरण प्रकाशिकी",
    "तरंग प्रकाशिकी",
    "विकिरण तथा द्रव्य की द्वैत प्रकृति",
    "परमाणु",
    "नाभिक",
    "अर्धचालक इलेक्ट्रॉनिकी",
  ],
  Chemistry: [
    "विलयन",
    "वैद्युत रसायन",
    "रासायनिक बलगतिकी",
    "d- एवं f-ब्लॉक के तत्व",
    "उपसहसंयोजन यौगिक",
    "हैलोऐल्केन तथा हैलोऐरीन",
    "ऐल्कोहॉल, फ़ीनॉल एवं ईथर",
    "ऐल्डिहाइड एवं कीटोन",
    "ऐमीन",
    "जैव-अणु",
  ],
  Maths: [
    "संबंध एवं फलन",
    "प्रतिलोम त्रिकोणमितीय फलन",
    "आव्यूह",
    "सारणिक",
    "सांतत्य तथा अवकलनीयता",
    "अवकलज के अनुप्रयोग",
    "समाकलन",
    "समाकलनों के अनुप्रयोग",
    "अवकल समीकरण",
    "सदिश",
    "त्रिविमीय ज्यामिति",
    "रैखिक प्रोग्रामन",
    "प्रायिकता",
  ],
};

export function syllabusFor(locale: Locale): Record<SubjectKey, string[]> {
  return locale === "hi" ? SYLLABUS_HI : SYLLABUS;
}

/** "Physics" → "भौतिकी" in Hindi. Unknown subjects pass through. */
export function subjectName(subject: string, locale: Locale) {
  const key = subjectKey(subject) ?? subject;
  return dictionaries[locale].common.subjects[key] ?? subject;
}

/**
 * The display title of a course. The three PCM crash courses get a translated
 * title; anything else keeps the title set in the admin console.
 */
export function courseTitle(course: { title: string; subjects: string[]; price?: number }, locale: Locale) {
  if (locale === "en" || course.subjects.length !== 1) return course.title;
  const key = subjectKey(course.subjects[0]);
  if (!key || !/crash course/i.test(course.title)) return course.title;
  return dictionaries.hi.common.courseTitle(dictionaries.hi.common.subjects[key]);
}

/** The stored validity line ("Until 31 March 2027") in the visitor's language. */
export function validityText(value: string | undefined | null, locale: Locale) {
  const d = dictionaries[locale].common.validityDefault;
  if (!value || value === dictionaries.en.common.validityDefault) return d;
  return value;
}
