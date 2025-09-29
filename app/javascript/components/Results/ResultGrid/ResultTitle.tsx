import React, { ReactNode } from 'react';

interface ResultTitleProps {
  url: string;
  className?: string;
  clickTracking?: () => void;
  children: ReactNode;
}

const ResultTitle = ({ url, clickTracking, className, children }: ResultTitleProps) => {
  return (
    <a 
      tabIndex={-1} // Prevent tabbing to the link since the entire result div is already focusable
      href={url}
      className={className}
      onClick={() => clickTracking && clickTracking()}>
      {children}
    </a>
  );
};

export default ResultTitle;
