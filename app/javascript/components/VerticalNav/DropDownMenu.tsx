import React, { useState, useContext, ReactNode, createRef, useEffect, RefObject } from 'react';
import { LanguageContext } from '../../contexts/LanguageContext';
import { NavDropDownButton, Menu } from '@trussworks/react-uswds';

interface DropDownMenuProps {
  label: string,
  items: ReactNode[]
}

export const DropDownMenu = ({ label, items }: DropDownMenuProps) => {
  const i18n = useContext(LanguageContext);
  const [openMore, setOpenMore] = useState(false);
  const btnRef: RefObject<HTMLDivElement> = createRef();

  useEffect(() => {
    const closeDropDown = (event: Event) => {
      if (btnRef.current && !btnRef.current.contains(event.target as HTMLDivElement)) {
        setOpenMore(false);
      }
    };

    document.body.addEventListener('click', closeDropDown);

    return () => document.body.removeEventListener('click', closeDropDown);
  });

  return (
    <div ref={btnRef}>
      <NavDropDownButton
        menuId="nav-menu"
        onToggle={() => setOpenMore((prev) => !prev)}
        isOpen={openMore}
        label={i18n.t(label)}
      />
      <Menu items={items} isOpen={openMore} id="nav-menu" />
    </div>
  );
};
