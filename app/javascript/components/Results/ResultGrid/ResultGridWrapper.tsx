import React, { useState, useEffect, ReactNode } from 'react';
import { Grid } from '@trussworks/react-uswds';
interface ResultGridWrapperProps {
  url: string;
  clickTracking?: () => void;
  children: ReactNode;
}

const ResultGridWrapper = ({ url, clickTracking, children }: ResultGridWrapperProps) => {
  const [isResultDivClickable, setIsResultDivClickable] = useState(false);
  
  const isMobile = () => {
    return window.innerWidth <= 767;
  };
  
  const handleResultDivClick = (url: string) => {
    // if (isResultDivClickable) {
    //   if (clickTracking)  
    //     clickTracking();
    //   window.location.href = url;
    // }
    if (clickTracking)  
      clickTracking();
    window.location.href = url;
  };

  useEffect(() => {
    setIsResultDivClickable(isMobile());
  }, []);
  
  return (
    <Grid 
      row gap='md' 
      className='result-meta-grid-wrapper'
      tabIndex={0} // Makes it keyboard focusable
      role='link' // Announce as link to screen readers
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          handleResultDivClick(url);
        }
      }}
      onClick={() => handleResultDivClick(url)}>
      {children}
    </Grid>
  );
};

export default ResultGridWrapper;
