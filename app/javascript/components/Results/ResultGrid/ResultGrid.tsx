import React, {useState, useEffect} from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { truncateUrl } from '../../../utils';

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
  youtubeDuration?: string
};

interface ResultProps {
  result: Result;
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

export const ResultGrid = ({ result }: ResultProps) => {  
  const URL_LENGTH = 80;
  const [isClickable, setIsClickable] = useState(false);

  // Detect if the device is a mobile device
  const isMobile = () => {
    return window.innerWidth <= 480;
  };

  // Update the state of the div based on the device type
  useEffect(() => {
    setIsClickable(isMobile());
  }, []);

  const handleClick = () => {
  // Do something when the div is clicked
    console.log('Div was clicked!');
  };

  return (
    <GridContainer className='result search-result-item' onClick={isClickable ? handleClick : null}>
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
              <a href={result.url} className='result-title-link'>
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
