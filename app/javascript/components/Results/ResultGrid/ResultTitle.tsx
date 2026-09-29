import React, { ReactNode } from 'react';

interface ResultTitleProps {
  url: string;
  className?: string;
  clickTracking?: () => void;
  children: ReactNode;
  elementType?: 'anchor' | 'span';
}

const ResultTitle = ({ url, clickTracking, className, children, elementType = 'anchor' }: ResultTitleProps) => {
  return elementType === 'anchor' ? (
    <a href={url} className={className} onClick={() => clickTracking && clickTracking()}>
      {children}
    </a>
  ) : (
    <span className={className} onClick={() => clickTracking && clickTracking()}>
      {children}
    </span>
  );
};

export default ResultTitle;
