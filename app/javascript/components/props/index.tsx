import { PageData } from '../SearchResultsLayout';

export interface HeaderProps {
  page: PageData;
  toggleMobileNav(): void;
  mobileNavOpen: boolean;
}
