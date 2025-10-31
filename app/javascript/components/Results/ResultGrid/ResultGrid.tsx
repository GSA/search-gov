import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { clickTracking, truncateUrl } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import ResultGridWrapper from './ResultGridWrapper';
import ResultTitle from './ResultTitle';

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
  blendedModule?: string,
  tags?: string[]
};

interface ResultProps {
  result: Result;
  affiliate: string;
  position: number;
  query: string;
  vertical: string
  facetsEnabled?: boolean
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

const getFilterTags = (result: Result) => {
  // To remove the dummy tags with integration once backend starts sending the data
  const filterTags = result.tags || ['Small Business', 'Contracts'];
  return (
    <div className='filter-tags-wrapper'>
      {
        filterTags.map((filterTag, index) => <span className='filter-tag' key={index}>{filterTag}</span>)
      }
    </div>
  );
};

export const ResultGrid = ({ result, affiliate, query, position, vertical, facetsEnabled }: ResultProps) => {
  const URL_LENGTH = 80;
  const module = (() => {
    if (vertical === 'blended') {
      return `${result.blendedModule}`;
    }
    const moduleKey = `web${vertical.charAt(0).toUpperCase() + vertical.slice(1)}`;
    return moduleCode[moduleKey as keyof typeof moduleCode];
  })();
  const finalTitle = result.title || result.url;

  return (
    <GridContainer className='result search-result-item cursor-pointer'>
      <ResultGridWrapper
        url={result.url}
        clickTracking={() => clickTracking(affiliate, module, query, position, result.url, vertical)}>
        {/* Stop displaying image issue SRCH-6000
        {result.thumbnailUrl &&
        <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
          <img src={result.thumbnailUrl} className="result-image" alt={result.title}/>
        </Grid>
        }
        */}
        <Grid col={true} className='result-meta-data'>
          {result.publishedDate && <span className='published-date'>{result.publishedDate}</span>}
          {result.updatedDate   && <span className='published-date'>{' '}&#40;Updated on {result.updatedDate}&#41;</span>}
          {result.publishedAt   && <span className='published-date'>{result.publishedAt}</span>}
          <div className='result-title'>
            <h2 className='result-title-label'>
              <ResultTitle
                className='result-title-link'>
                {parse(finalTitle)}
                {getFileType(result.fileType)}
              </ResultTitle>
            </h2>
          </div>
          <div className='result-desc'>
            {getDescription(result.description)}
            <div className='result-url-text'>{truncateUrl(result.url, URL_LENGTH)}</div>
            {facetsEnabled && getFilterTags(result)}
          </div>
        </Grid>
      </ResultGridWrapper>
      <Grid row className="row-mobile-divider"></Grid>
    </GridContainer>
  );
};
