repo: Genziitian/Ab_academy
branch: main
path: apps/web

## Last sync
date: 2026-10-12T06:54:56Z

### Updated in this project
- Redesigned public site in IBM Plex Sans, keeping the existing blue/navy palette
- Added a web student portal based on the mobile app's features
- Removed course community chat rooms; kept lecture discussion and doubts
- Refocused on Class 11 & 12 crash courses; menu is Courses + Notes
- Added 26 mobile app screens (Notes tab replaces Community)

## Screen map
| Screen | Repo files |
|---|---|
| SiteHeader / SiteFooter | apps/web/src/components/SiteHeader.tsx, SiteFooter.tsx |
| Home | apps/web/src/app/(site)/page.tsx, components/CourseCard.tsx |
| Courses | apps/web/src/components/CoursesCatalog.tsx, lib/courses.ts |
| Course Detail | apps/web/src/app/(site)/course/[slug]/page.tsx, components/CurriculumAccordion.tsx |
| For Students / About / Contact / Legal | apps/web/src/app/(site)/for-students, about, contact, privacy, terms |
| Login | apps/web/src/app/(site)/login/*, apps/mobile/lib/screens/onboarding/* |
| Dashboard | apps/mobile/lib/screens/home/home_screen.dart |
| My Courses | apps/mobile/lib/screens/courses/* |
| Lecture | apps/mobile/lib/screens/lessons/lecture_screen.dart |
| Live Classes / Live Classroom | apps/mobile/lib/screens/live/* |
| Calendar, Study Materials, Downloads, Notifications, Support Tickets, Profile, Checkout | apps/mobile/lib/screens/*, apps/mobile/lib/data/mock/mock_data.dart |
| Notes | apps/web/src/lib/courses.ts, apps/mobile/lib/screens/materials/study_materials_screen.dart |
| Mobile App - Onboarding | apps/mobile/lib/screens/onboarding/* |
| Mobile App - Learn | apps/mobile/lib/screens/home/*, courses/*, lessons/* |
| Mobile App - Live | apps/mobile/lib/screens/live/*, calendar/* |
| Mobile App - Library and Account | apps/mobile/lib/screens/materials/*, downloads/*, notifications/*, profile/*, tickets/* |
| Mobile App - Purchase | apps/mobile/lib/screens/purchase/* |
