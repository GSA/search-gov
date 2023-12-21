import { PageData } from '../SearchResultsLayout';

export interface HeaderProps {
  page: PageData;
  toggleMobileNav(): void;
  mobileNavOpen: boolean;
  primaryHeaderLinks?: {
    title: string,
    url: string
  }[];
  secondaryHeaderLinks?: {
    title: string,
    url: string
  }[];
}
