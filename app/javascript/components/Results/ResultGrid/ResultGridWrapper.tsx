import React, { useState, useEffect, ReactNode } from 'react';
import { Grid } from '@trussworks/react-uswds';
interface ResultGridWrapperProps {
  url: string;
  clickTracking?: () => void;
  children: ReactNode;
}

const ResultGridWrapper = ({ url, clickTracking, children }: ResultGridWrapperProps) => {
  const [isResultDivClickable, setIsResultDivClickable] = useState(false);
  
  // Handle keydown events for accessibility
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    // Only trigger on Enter or Space key presses
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault(); // Prevent default behavior for space key
      handleResultDivClick(url)
    }
  };

  const handleResultDivClick = (url: string) => {
    if (isResultDivClickable) {
      if (clickTracking)  
        clickTracking();
      window.location.href = url;
    }
  };

  useEffect(() => {
    setIsResultDivClickable(true);
  }, []);
  
  return (
    <Grid 
      tabIndex={0} // Make the div focusable
      row gap='md'
      className='result-meta-grid-wrapper'
      onClick={() => handleResultDivClick(url)}
      onKeyDown={handleKeyDown} // Add keydown event listener
      >
      {children}
    </Grid>
  );
};

export default ResultGridWrapper;
