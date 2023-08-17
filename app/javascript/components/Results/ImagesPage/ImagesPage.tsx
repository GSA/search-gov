import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

export const ImagesPage = () => {
  const imagesToBeDynamic = [
    {
      url: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 1'
    },
    {
      url: 'https://images.unsplash.com/flagged/photo-1552483570-019b7f8119b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 2'
    },
    {
      url: 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bmFzYXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 3'
    },
    {
      url: 'https://images.unsplash.com/photo-1502134249126-9f3755a50d78?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bmFzYXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 4'
    },
    {
      url: 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNhbHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 5'
    }
  ];
  
  return (
    <GridContainer className='result search-result-item search-result-image-item'>
      <Grid row gap="md">
        {(imagesToBeDynamic.map((image, index) => {
          return (
            <Grid key={index} mobileLg={{ col: 4 }} className='result-thumbnail margin-bottom-4'>
              <img src={image.url} className="result-image" alt={image.title} />
            </Grid>
          );
        }))}
      </Grid>
    </GridContainer>
  );
};
