<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	//세션 유효성 검사(로그인 유무)
	if(session.getAttribute("loginMemberId") == null) { // 로그인이 되어있지 않다면
		response.sendRedirect(request.getContextPath()+"/login.jsp"); // 로그인 페이지로
		return;
	}
	// 로그인 아이디 정보 저장
	String memberId = (String)session.getAttribute("loginMemberId");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>add board + file</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container mt-3">
		<h1 style="text-align: center;">PDF 자료 업로드</h1>
		<a  type="button" class="btn btn-outline-secondary" href = "<%=request.getContextPath()%>/boardList.jsp">목록으로</a>
		<br>
		<form method="post" enctype="multipart/form-data" action="<%=request.getContextPath()%>/addBoardAction.jsp">
			<table class="table table-hover">
				<!-- 자료 업로드 제목글 -->
				<tr>
					<th>자료명</th>
					<td>
						<textarea rows="3" cols="50" name="boardTitle" required="required"></textarea>
					</td>
				</tr>
				<tr>
					<th>작성자</th>
					<td>
						<input type="text" name="memberId" value="<%=memberId%>" readonly="readonly">
					</td>
				</tr>
				<tr>
					<th>파일선택</th>
					<td>
						<input type="file" name="boardFile" required="required">
					</td>
				</tr>
			</table>
			<button type="submit" class="btn btn-outline-secondary">자료업로드</button>
		</form>
	</div>
</body>
</html>