export interface HeaderProps {
  title: string;
  toggleMobileNav(): void;
  mobileNavOpen: boolean;
  fontsAndColors: {
    headerLinksFontFamily: string;
  };
}
