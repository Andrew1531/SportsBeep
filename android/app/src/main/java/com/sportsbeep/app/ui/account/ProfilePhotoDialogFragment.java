package com.sportsbeep.app.ui.account;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.user.PhotoResponse;
import com.sportsbeep.app.task.HeadshotTask;
import com.sportsbeep.app.task.network.RemoveAvatarAsyncTask;
import com.sportsbeep.app.task.network.UploadAvatarAsyncTask;
import com.sportsbeep.app.ui.base.BaseDialogFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.typed.TypedUri;
import com.squareup.picasso.Picasso;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.Toast;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Optional;

public class ProfilePhotoDialogFragment extends BaseDialogFragment implements TypedUri.ProgressListener {

    private static final String TAG = ProfilePhotoDialogFragment.class.getSimpleName();

    private static final int REQUEST_CODE_PICKER = 101;

    private static final int REQUEST_CODE_CAMERA = 100;

    private static final float MENU_WIDTH = 260f;

    FontTextView mNameFontTextView;

    ImageView mPhotoImageView;

    PopupWindow mPopupWindow;

    ProgressDialog mDialog;

    HeadshotTask mHeadshotTask;

    Uri mImageUri;

    boolean mRemove;

    public static ProfilePhotoDialogFragment newInstance() {
        return new ProfilePhotoDialogFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_profile_photo, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        View menuView = LayoutInflater.from(getActivity()).inflate(R.layout.menu_profile_photo, null);
        ButterKnife.inject(this, menuView);

        mNameFontTextView = ButterKnife.findById(view, R.id.name_FontTextView);
        mPhotoImageView = ButterKnife.findById(view, R.id.profilePhoto_ImageView);

        String firstName = getPreferences().getFirstName();
        String lastName = getPreferences().getLastName();
        String username = getPreferences().getUsername();
        if (firstName != null && lastName != null) {
            mNameFontTextView.setText(firstName + " " + lastName);
        } else if (username != null) {
            mNameFontTextView.setText(username);
        } else {
            mNameFontTextView.setVisibility(View.GONE);
        }

        String avatarUrl = getPreferences().getAvatarUrl();
        if (!TextUtils.isEmpty(avatarUrl)) {
            mHeadshotTask = new HeadshotTask(getActivity(), mPhotoImageView);
            mHeadshotTask.execute(avatarUrl);
        }

        float width = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, MENU_WIDTH, getResources().getDisplayMetrics());
        mPopupWindow = new PopupWindow(menuView, (int) width, ViewGroup.LayoutParams.WRAP_CONTENT);

        mDialog = new ProgressDialog(getActivity());
        mDialog.setCancelable(false);
        mDialog.setMax(100);
    }

    @Override
    public void onDestroyView() {
        if (mHeadshotTask != null) {
            mHeadshotTask.cancel();
        }
        super.onDestroyView();
    }

    @Optional
    @OnClick(R.id.profilePhoto_ImageView)
    public void onPhotoClicked(View v) {
        if (mPopupWindow.isShowing()) {
            mPopupWindow.dismiss();
        } else {
            mPopupWindow.showAtLocation(v, Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM, 0, 0);
        }
    }

    @Optional
    @OnClick(R.id.save_FontTextView)
    public void onSaveClicked() {
        if (mImageUri == null && !mRemove) {
            dismiss();
            return;
        }

        if (mImageUri != null) {
            TypedUri typedUri = new TypedUri(getActivity(), mImageUri, "image/*");
            typedUri.setListener(this);

            new UploadAvatarTask().execute(typedUri);
        } else if (mRemove) {
            new RemoveAvatarTask().execute();
        }
    }

    @Optional
    @OnClick(R.id.cancel_FontTextView)
    public void onCancelClicked() {
        dismiss();
    }

    @Optional
    @OnClick(R.id.uploadPhoto_FontTextView)
    public void onUploadPhotoClicked() {
        if (getActivity() == null) {
            return;
        }

        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");

        if (intent.resolveActivity(getActivity().getPackageManager()) != null) {
            startActivityForResult(intent, REQUEST_CODE_PICKER);
        } else {
            Toast.makeText(getActivity(), R.string.image_picker_error, Toast.LENGTH_LONG).show();
        }

        mPopupWindow.dismiss();
    }

    @Optional
    @OnClick(R.id.takePhoto_FontTextView)
    public void onTakePhotoClicked() {
        if (getActivity() == null) {
            return;
        }

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        if (intent.resolveActivity(getActivity().getPackageManager()) != null) {
            mImageUri = getOutputPhotoUri();
            if (mImageUri != null) {
                intent.putExtra(MediaStore.EXTRA_OUTPUT, mImageUri);
                startActivityForResult(intent, REQUEST_CODE_CAMERA);
            } else {
                Toast.makeText(getActivity(), R.string.file_error, Toast.LENGTH_LONG).show();
            }
        } else {
            Toast.makeText(getActivity(), R.string.camera_error, Toast.LENGTH_LONG).show();
        }

        mPopupWindow.dismiss();
    }

    @Optional
    @OnClick(R.id.remove_FontTextView)
    public void onRemoveClicked() {
        if (getActivity() == null) {
            return;
        }

        mImageUri = null;
        mRemove = true;
        mPhotoImageView.setImageResource(R.drawable.player_silhouette_circle);

        mPopupWindow.dismiss();
    }

    @Optional
    @OnClick(R.id.cancelContext_FontTextView)
    public void onCancelContextClicked() {
        if (getActivity() == null) {
            return;
        }

        mPopupWindow.dismiss();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_PICKER) {
            if (resultCode == Activity.RESULT_OK) {
                mImageUri = data.getData();
            }
        }

        if (mImageUri != null) {
            mHeadshotTask = new HeadshotTask(getActivity(), mPhotoImageView);
            mHeadshotTask.execute(mImageUri.toString());
        }
    }

    private Uri getOutputPhotoUri() {
        String appName = getString(R.string.app_name);
        File pictureDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), appName);

        if (!pictureDir.exists()) {
            if (!pictureDir.mkdirs()) {
                Log.e(TAG, "Unable to create directory for photos.");
                return null;
            }
        }

        String timestamp = new SimpleDateFormat("yyyMMdd_HHmmss").format(new Date());
        File file = new File(pictureDir.getPath() + File.separator + "IMG_" + timestamp + ".png");

        return Uri.fromFile(file);
    }

    @Override
    public void onProgress(final int percent) {
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mDialog.setProgress(percent);
            }
        });
    }

    @Override
    public void onFinish() {
        // no-op
    }

    public class RemoveAvatarTask extends RemoveAvatarAsyncTask {

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mDialog.setMessage(getString(R.string.removing_photo));
            mDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            mDialog.show();
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            mDialog.dismiss();
        }

        @Override
        protected void onSuccess(PhotoResponse photoResponse) {
            super.onSuccess(photoResponse);
            getPreferences().setAvatarUrl(photoResponse.getAvatarUrl());
            Toast.makeText(getActivity(), R.string.photo_removed, Toast.LENGTH_SHORT).show();
            dismiss();
        }
    }

    public class UploadAvatarTask extends UploadAvatarAsyncTask {

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mDialog.setMessage(getString(R.string.uploading_photo));
            mDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
            mDialog.show();
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            mDialog.dismiss();
        }

        @Override
        protected void onSuccess(PhotoResponse photoResponse) {
            super.onSuccess(photoResponse);
            getPreferences().setAvatarUrl(photoResponse.getAvatarUrl());
            Toast.makeText(getActivity(), R.string.photo_updated, Toast.LENGTH_SHORT).show();

            // warm the cache
            Picasso.with(getActivity()).load(photoResponse.getAvatarUrl()).fetch();

            dismiss();
        }
    }
}
