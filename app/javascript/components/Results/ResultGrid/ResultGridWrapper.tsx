import React, { useState, useEffect, ReactNode } from 'react';
import { Grid } from '@trussworks/react-uswds';
interface ResultGridWrapperProps {
  url: string;
  clickTracking?: () => void;
  children: ReactNode;
}

const ResultGridWrapper = ({ url, clickTracking, children }: ResultGridWrapperProps) => {
  const [isResultDivClickable, setIsResultDivClickable] = useState(false);
  const [mobileResultDivStyle, setMobileResultDivStyle] = useState('');
  
  const isMobile = () => {
    return window.innerWidth <= 767;
  };
  
  const handleResultDivClick = (url: string) => {
    if (isResultDivClickable) {
      if (clickTracking)  
        clickTracking();

      
      //[...document.getElementsByClassName('mobile-outline')].forEach((c)=>c.)
      //[...document.getElementsByClassName('mobile-outline')][0].classList.remove('mobile-outline')
      setMobileResultDivStyle('mobile-outline');
      window.location.href = url;
    }
  };

  useEffect(() => {
    setIsResultDivClickable(isMobile());
  }, []);
  
  return (
    <Grid 
      row gap="md" 
      onClick={() => handleResultDivClick(url)}
      className={mobileResultDivStyle}>
      {children}
    </Grid>
  );
};

export default ResultGridWrapper;
