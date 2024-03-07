import React, { ReactNode } from 'react';

interface ResultTitleProps {
  url: string;
  clickTracking?: () => void;
  children: ReactNode;
}

const ResultTitle = ({ url, clickTracking, children }: ResultTitleProps) => {
  return (
    <a 
      href={url}
      className='result-title-link'
      onClick={() => clickTracking && clickTracking()}>
      {children}
    </a>
  );
};

export default ResultTitle;
