"use client";

import Link from "next/link";
import { useCallback, useEffect, useRef, useState } from "react";
import { CourseCard } from "@/components/CourseCard";
import type { Course } from "@/lib/courses";

const GAP = 20;
const AUTOPLAY_MS = 5000;

/**
 * Horizontally scrolling row of featured courses with prev/next buttons, dots
 * and a 5-second autoplay that stops as soon as the visitor touches a control.
 */
export function FeaturedCarousel({ courses }: { courses: Course[] }) {
  const track = useRef<HTMLDivElement>(null);
  const [page, setPage] = useState(0);
  const [pages, setPages] = useState(Math.max(1, courses.length - 2));
  const [autoplay, setAutoplay] = useState(true);

  const cardWidth = () => {
    const card = track.current?.firstElementChild;
    return card ? card.getBoundingClientRect().width + GAP : 320;
  };

  const step = useCallback((direction: 1 | -1, wrap = false) => {
    const el = track.current;
    if (!el) return;
    const max = el.scrollWidth - el.clientWidth;
    let left = el.scrollLeft + direction * cardWidth();
    if (left > max + 4) left = wrap ? 0 : max;
    if (left < 0) left = 0;
    el.scrollTo({ left, behavior: "smooth" });
  }, []);

  useEffect(() => {
    if (!autoplay) return;
    const id = setInterval(() => step(1, true), AUTOPLAY_MS);
    return () => clearInterval(id);
  }, [autoplay, step]);

  // Number of dots = how many distinct scroll stops the track has.
  useEffect(() => {
    const el = track.current;
    if (!el) return;
    const measure = () => {
      const perView = Math.max(1, Math.round(el.clientWidth / cardWidth()));
      setPages(Math.max(1, courses.length - perView + 1));
    };
    measure();
    window.addEventListener("resize", measure);
    return () => window.removeEventListener("resize", measure);
  }, [courses.length]);

  function goTo(index: number) {
    setAutoplay(false);
    track.current?.scrollTo({ left: index * cardWidth(), behavior: "smooth" });
  }

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <p className="eyebrow">Popular crash courses</p>
          <h2 className="mt-2.5 text-[28px] font-bold tracking-[-0.02em] text-navy sm:text-[34px]">
            Start your board revision
          </h2>
        </div>
        <div className="flex items-center gap-2">
          <Link
            href="/courses"
            className="mr-2 whitespace-nowrap text-sm font-semibold text-primary hover:text-primary-dark"
          >
            View all
          </Link>
          <button
            type="button"
            aria-label="Previous courses"
            onClick={() => {
              setAutoplay(false);
              step(-1);
            }}
            className="size-[42px] rounded-lg border border-border bg-white text-lg text-navy hover:border-primary hover:text-primary"
          >
            ‹
          </button>
          <button
            type="button"
            aria-label="Next courses"
            onClick={() => {
              setAutoplay(false);
              step(1, true);
            }}
            className="size-[42px] rounded-lg bg-primary text-lg text-white hover:bg-primary-dark"
          >
            ›
          </button>
        </div>
      </div>

      <div
        ref={track}
        onScroll={(event) => {
          const next = Math.round(event.currentTarget.scrollLeft / cardWidth());
          if (next !== page) setPage(next);
        }}
        className="no-scrollbar mt-8 grid snap-x snap-mandatory auto-cols-[minmax(280px,85%)] grid-flow-col gap-5 overflow-x-auto pb-1 sm:auto-cols-[minmax(300px,calc((100%-20px)/2))] lg:auto-cols-[minmax(300px,calc((100%-40px)/3))]"
      >
        {courses.map((course) => (
          <CourseCard
            key={course.slug}
            course={course}
            variant="featured"
            className="snap-start"
          />
        ))}
      </div>

      <div className="mt-5 flex justify-center gap-1.5">
        {Array.from({ length: pages }, (_, index) => (
          <button
            key={index}
            type="button"
            aria-label={`Go to slide ${index + 1}`}
            onClick={() => goTo(index)}
            className={`h-2 rounded transition-[width] duration-200 ${
              page === index ? "w-6 bg-primary" : "w-2 bg-[#d5dcea]"
            }`}
          />
        ))}
      </div>
    </>
  );
}
