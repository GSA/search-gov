export interface HeaderProps {
  title: string;
  logoUrl: string;
  toggleMobileNav(): void;
  mobileNavOpen: boolean;
  fontsAndColors: {
    headerLinksFontFamily: string;
  };
}
