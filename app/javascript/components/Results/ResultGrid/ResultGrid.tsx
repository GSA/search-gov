import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { clickData, clickTracking, truncateUrl } from '../../../utils';
import { moduleCode } from '../../../utils/constants';

type Result = {
  title: string,
  url: string,
  description: string,
  updatedDate?: string,
  publishedAt?: string,
  publishedDate?: string,
  fileType?: string;
  thumbnailUrl?: string,
  image?: boolean,
  altText?: string,
  youtube?: boolean,
  youtubePublishedAt?: string,
  youtubeThumbnailUrl?: string,
  youtubeDuration?: string,
  blendedModule?: string
};

interface ResultProps {
  result: Result;
  affiliate: string;
  position: number;
  query: string;
  vertical: string
}

const getDescription = (description: string) => {
  if (!description) {
    return;
  }
  return (<p>{parse(description)}</p>);
};

const getFileType = (fileType?: string) => {
  if (!fileType) {
    return;
  }
  return (<span className='filetype-label'>{fileType}</span>);
};

export const ResultGrid = ({ result, affiliate, query, position, vertical }: ResultProps) => {  
  const URL_LENGTH = 80;
  const module = (() => {
    if (vertical === 'blended') {
      return `${result.blendedModule}`;
    }
    const moduleKey = `web${vertical.charAt(0).toUpperCase() + vertical.slice(1)}`;
    return moduleCode[moduleKey as keyof typeof moduleCode];
  })();

  return (
    <GridContainer className='result search-result-item'>
      <Grid row gap="md">
        {result.thumbnailUrl &&
        <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
          <img src={result.thumbnailUrl} className="result-image" alt={result.title}/>
        </Grid>
        }
        <Grid col={true} className='result-meta-data'>
          {result.publishedDate && <span className='published-date'>{result.publishedDate}</span>}
          {result.updatedDate   && <span className='published-date'>{' '}&#40;Updated on {result.updatedDate}&#41;</span>}
          {result.publishedAt   && <span className='published-date'>{result.publishedAt}</span>}
          <div className='result-title'>
            <h2 className='result-title-label'>
              <a href={result.url}
                className='result-title-link'
                data-click={clickData(affiliate, module, query, position, result.url, vertical)}
                onClick={(event) => clickTracking((event.target as HTMLLinkElement).getAttribute('data-click') || '{}')}>
                {parse(result.title)} 
                {getFileType(result.fileType)}
              </a>
            </h2>
          </div>
          <div className='result-desc'>
            {getDescription(result.description)}
            <div className='result-url-text'>{truncateUrl(result.url, URL_LENGTH)}</div>
          </div>
        </Grid>
      </Grid>
      <Grid row className="row-mobile-divider"></Grid>
    </GridContainer>
  );
};
