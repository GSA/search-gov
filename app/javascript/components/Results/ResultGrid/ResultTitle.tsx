import React, { ReactNode } from 'react';
import { clickTracking } from 'utils';

interface ResultTitleProps {
  url?: string;
  className?: string;
  clickTracking?: () => void;
  children: ReactNode;
}

const ResultTitle = ({ url, clickTracking, className, children }: ResultTitleProps) => {
  return (
    <>
      {url && clickTracking?
        <a 
          href={url}
          className={className}
          onClick={() => clickTracking && clickTracking()}>
          {children}
        </a>
        :
        <div
          className={className}
          >
          {children}
        </div>
      }
    </>
  );
};

export default ResultTitle;
