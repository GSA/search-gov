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
      href={url}
      className={className}
      onClick={() => clickTracking && clickTracking()}>
      {children}
    </a>
  );
};

export default ResultTitle;
