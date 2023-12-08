import { createContext } from 'react';

// Default fonts and colors
const styles = {
  activeSearchTabNavigationColor: '#005EA2',
  bannerBackgroundColor: '#F0F0F0',
  bannerTextColor: '#1B1B1B',
  bestBetBackgroundColor: '#1A4480',
  buttonBackgroundColor: '#005EA2',
  footerBackgroundColor: '#F0F0F0',
  footerLinksTextColor: '#1B1B1B',
  headerBackgroundColor: '#FFFFFF',
  headerLinksFontFamily: '"Public Sans Web", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol"',
  headerPrimaryLinkColor: '#565C65',
  headerSecondaryLinkColor: '#71767A',
  healthBenefitsHeaderBackgroundColor: '#EFF6FB',
  identifierBackgroundColor: '#1B1B1B',
  identifierHeadingColor: '#FFFFFF',
  identifierLinkColor: '#A9AEB1',
  pageBackgroundColor: '#FFFFFF',
  resultDescriptionColor: '#1B1B1B',
  resultTitleColor: '#005EA2',
  resultTitleLinkVisitedColor: '#54278F',
  resultUrlColor: '#446443',
  searchTabNavigationLinkColor: '#005EA2',
  secondaryHeaderBackgroundColor: '#FFFFFF',
  sectionTitleColor: '#565C65'
};

export const StyleContext = createContext(styles);
