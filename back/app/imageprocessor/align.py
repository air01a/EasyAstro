from skimage.transform import SimilarityTransform
from ..models.image import Image
import numpy
import astroalign as aa


def apply_transformation( image: Image, transformation: SimilarityTransform, _last_stacking_result: Image):

    if image.is_color():
            results_dict = dict()

            for channel in range(3):
                apply_single_channel_transformation(image,
                                                    _last_stacking_result,
                                                    transformation,
                                                    results_dict,
                                                    channel)
            for channel, data in results_dict.items():
                image.data[channel] = data

    else:
        result_dict = dict()

        apply_single_channel_transformation(
            image,
            _last_stacking_result,
            transformation,
            result_dict
        )

        image.data = result_dict[0]
    #numpy.float32(aa.apply_transform(transformation, image, _last_stacking_result))

def apply_single_channel_transformation(image, reference, transformation, results_dict, channel=None):
    """
    apply a transformation on a specific channel (RGB) of a color image, or whole data of a b&w image.
    :param image: the image to apply transformation to
    :type image: Image
    :param reference: the align reference image
    :type reference: Image
    :param transformation: the transformation to apply
    :type transformation: skimage.transform._geometric.SimilarityTransform
    :param results_dict: the dict into which transformation result is to be stored. dict key is the channel number
            for a color image, or 0 for a b&w image
    :type results_dict: dict
    :param channel: the 0 indexed number of the color channel to process (0=red, 1=green, 2=blue)
    :type channel: int
    """

    if channel is not None:
        target_index = channel
        source_data = image.data[channel]
        reference_data = reference.data[channel]
    else:
        target_index = 0
        source_data = image.data
        reference_data = reference.data
    

    aligned = aa.apply_transform(transformation, source_data, reference_data)[0]
    results_dict[target_index] = numpy.float32(aligned)



def find_transformation( image: Image, align_reference : Image):

   # for ratio in ratios:
    top, bottom, left, right = get_image_subset_boundaries(1.,align_reference)
        # pick green channel if image has color
    if image.is_color():
        new_subset = image.data[1][top:bottom, left:right]
        ref_subset = align_reference.data[1][top:bottom, left:right]
    else:
        new_subset = image.data[top:bottom, left:right]
        ref_subset = align_reference.data[top:bottom, left:right]

    try:
        transformation, matches = aa.find_transform(new_subset, ref_subset)
        matches_count = len(matches[0])
        if matches_count < 25:
            print('error not enough stars')
        return transformation

    # pylint: disable=W0703
    except Exception as alignment_error:
        # we have no choice but catching Exception, here. That's what AstroAlign raises in some cases
        # this will catch MaxIterError as well...
        print('alignement error')
        return None
    
def get_image_subset_boundaries(ratio: float, last_stacking_result):
    """
    Retrieves a tuple of 4 int values representing the limits of a centered box (a.k.a. subset) as big as
    ratio * stored stacking result's size
    :param ratio: size ratio of subset vs stacking result
    :type ratio: float
    :return: a tuple of 4 int for top, bottom, left, right
    :rtype: tuple
    """

    width = last_stacking_result.width
    height =last_stacking_result.height

    horizontal_margin = int((width - (width * ratio)) / 2)
    vertical_margin = int((height - (height * ratio)) / 2)

    left = 0 + horizontal_margin
    right = width - horizontal_margin - 1
    top = 0 + vertical_margin
    bottom = height - vertical_margin - 1

    return top, bottom, left, right