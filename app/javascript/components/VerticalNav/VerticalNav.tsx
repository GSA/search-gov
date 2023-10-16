import React, { useState, useEffect, useContext, ReactNode } from 'react';
import { GridContainer, Header, NavDropDownButton, Menu, PrimaryNav } from '@trussworks/react-uswds';
import { NavigationLink } from '../SearchResultsLayout';
import { LanguageContext } from '../../contexts/LanguageContext';

import './VerticalNav.css';

interface VerticalNavProps {
  relatedSites?: {label: string, link: string}[];
  navigationLinks: NavigationLink[];
}

const getTextWidth = (text: string) => {
  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d');

  if (context) {
    context.font = getComputedStyle(document.body).font;

    return context.measureText(text).width;
  }

  return 0;
};

export const VerticalNav = ({ relatedSites = [], navigationLinks = [] }: VerticalNavProps) => {
  const i18n = useContext(LanguageContext);
  const [openMore, setOpenMore] = useState(true);
  const [navItems, setNavItems] = useState<ReactNode[]>([]);
  const [navItemsCount, setNavItemsCount] = useState(0);

  const onToggle = (setOpenMore: React.Dispatch<React.SetStateAction<boolean>>) => {
    console.log(`before: ${ openMore }`);

    setOpenMore((last) => {
      console.log(` last: ${ last }`);

      return !last;
    });
  };

  const buildLink = ({ active, label, href }: NavigationLink, key = 0) => <a href={href} key={key} className={ active && 'usa-current' || '' }>{label}</a>;
  const buildNavLink = (label: string, items: ReactNode[]) => {
    return <>
      <NavDropDownButton
        menuId="nav-menu"
        onToggle={(): void => {
          onToggle(setOpenMore);
        }}
        isOpen={openMore}
        label={i18n.t(label)}
      />
      <Menu key={navItemsCount} items={items} isOpen={openMore} id="nav-menu" />
    </>;
  };

  const isThereEnoughSpace = () => {
    const container = document.getElementById('tabs-container');

    if (container) {
      const nav = container.getElementsByClassName('usa-nav__primary');

      if (nav && nav[0]) {
        return container.offsetWidth > ((nav[0] as HTMLElement).offsetWidth + itemToAddWidth());
      }
    }

    return false;
  };

  const itemToAddWidth = () => isLastItem() ? (currentNavItemWidth() + 160) : currentNavItemWidth();
  const currentNavItemWidth = () => getTextWidth(navigationLinks[navItemsCount].label) + 100;
  const isLastItem = () => navItemsCount === navigationLinks.length - 1;

  useEffect(() => {
    if ((navItemsCount < navigationLinks.length) && isThereEnoughSpace()) {
      setNavItems([...navItems, buildLink(navigationLinks[navItemsCount], navItemsCount)]);

      setNavItemsCount(navItemsCount + 1);
    } else {
      let items = navigationLinks.slice(navItemsCount).map(buildLink);
      const itemsLeft = items.length;

      if (itemsLeft) {
        items.push(<><hr /><i className="text-base-light">Related Sites</i></>);
        
        items = items.concat(relatedSites.map(({ link, label }, index) => <a href={link} key={index + itemsLeft}>{label}</a>));

        setNavItems([...navItems, buildNavLink('showMore', items)]);
      } else {
        items = relatedSites.map((site, index) => <a href={site.link} key={index}>{site.label}</a>);

        setNavItems([...navItems, buildNavLink('relatedSearches', items)]);
      }
    }
  }, [navItemsCount]);

  return (
    <div className="vertical-nav-wrapper">
      <GridContainer>
        <Header basic={true} className="vertical-wrapper">
          <div className="usa-nav-container" id="tabs-container">
            <PrimaryNav items={navItems} />
          </div>
        </Header>
      </GridContainer>
    </div>
  );
};
