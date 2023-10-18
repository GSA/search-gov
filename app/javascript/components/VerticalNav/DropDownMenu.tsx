import React, { useState, useContext, ReactNode } from 'react';
import { LanguageContext } from '../../contexts/LanguageContext';
import { NavDropDownButton, Menu } from '@trussworks/react-uswds';

interface DropDownMenuProps {
  label: string,
  items: ReactNode[]
}

export const DropDownMenu = ({ label, items }: DropDownMenuProps) => {
  const i18n = useContext(LanguageContext);
  const [openMore, setOpenMore] = useState(false);

  return <>
    <NavDropDownButton
      menuId="nav-menu"
      onToggle={() => setOpenMore((prev) => !prev)}
      isOpen={openMore}
      label={i18n.t(label)}
    />
    <Menu items={items} isOpen={openMore} id="nav-menu" />
  </>;
};
